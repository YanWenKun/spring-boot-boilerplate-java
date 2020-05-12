# 参考 Docker 官方推荐的最佳实践： https://www.docker.com/blog/intro-guide-to-dockerfile-best-practices/
# 请在编写完成后使用 Linter 检查： https://hadolint.github.io/hadolint/

# 使用分阶段构建，编译环境一个镜像，运行环境一个镜像
ARG BUILDER_IMAGE=maven:3-jdk-11-openj9
ARG RUNNER_IMAGE=adoptopenjdk:11-jre-openj9

# ===============================================

# 编译环境
FROM $BUILDER_IMAGE AS buildingStage

# 即使在容器中，也应当使用低特权用户
RUN mkdir -p /home/builder /build \
    && useradd builder -d /home/builder \
    && chown -R builder:builder /home/builder /build
USER builder:builder

# 配置 Maven 使用镜像源（阿里云）
COPY --chown=builder:builder docs/maven/settings.xml /home/builder/.m2/settings.xml

# 先让 Maven 解析并下载项目依赖，有利于 Docker 缓存
# 注意这里激活了 prod 配置集，如需其它配置集可按需修改
WORKDIR /build
COPY pom.xml .
RUN mvn --batch-mode \
        --quiet \
        --errors \
        --activate-profiles prod \
        dependency:go-offline

# 编译项目
# 注意这里跳过了测试环节，请根据流水线设计调整
# 注意这里激活了 prod 配置集，如需其它配置集可按需修改
COPY src ./src
RUN mvn --batch-mode \
        --quiet \
        --errors \
        --define maven.test.skip=true \
        --define java.awt.headless=ture \
        --activate-profiles prod \
        clean package

# ===============================================

# 运行环境
FROM $RUNNER_IMAGE AS runningStage

# 即使在容器中，也应当使用低特权用户
RUN mkdir -p /home/runner \
    && useradd runner -d /home/runner \
    && chown -R runner:runner /home/runner
USER runner:runner

EXPOSE 8080/tcp

WORKDIR /app

# 以下步骤会因项目代码变化而使构建缓存失效，因此放在最后
COPY --from=buildingStage /build/target/*.jar app.jar

# 使用 AOT 预热，以加快启动速度，缺点是缓存文件会增大镜像体积，因此以 -Xscmx -Xscmaxaot 参数做限制
# https://developer.ibm.com/technologies/java/articles/eclipse-openj9-class-sharing-in-docker-containers/
RUN sh -c 'java -Xshareclasses -Xscmx48M -Xscmaxaot16M -jar app.jar &' \
    ; sleep 30s \
    ; pgrep "java" | xargs kill

# OpenJ9 JVM 容器环境优化参数
# https://developer.ibm.com/technologies/java/articles/optimize-jvm-startup-with-eclipse-openjj9/
ENTRYPOINT ["java", "-Xshareclasses", "-Xtune:virtualized", "-jar", "app.jar"]
