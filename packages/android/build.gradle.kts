plugins {
    kotlin("jvm") version "2.1.10"
    `maven-publish`
}

group = "com.fadeanimation"
version = "0.1.0"

repositories {
    mavenCentral()
    google()
}

dependencies {
    compileOnly("org.robolectric:android-all:14-robolectric-10818077")
    compileOnly("androidx.annotation:annotation:1.7.1")

    testImplementation(platform("org.junit:junit-bom:5.10.2"))
    testImplementation("org.junit.jupiter:junit-jupiter")
    testImplementation("net.jqwik:jqwik:1.8.3")
    testImplementation("org.mockito:mockito-core:5.11.0")
    testImplementation("org.robolectric:android-all:14-robolectric-10818077")
    testRuntimeOnly("org.junit.platform:junit-platform-launcher")
}

kotlin {
    jvmToolchain(17)
}

tasks.test {
    useJUnitPlatform()
    testLogging {
        events("passed", "skipped", "failed")
    }
}

// 生成 sources jar，便于消费方查看/调试源码
java {
    withSourcesJar()
}

// 发布配置：`./gradlew publishToMavenLocal` 发到本地 ~/.m2，
// 或配置远程仓库后 `./gradlew publish` 发到私有 Maven。
// 产物坐标：com.fadeanimation:fade-animation-android:0.1.0
publishing {
    publications {
        create<MavenPublication>("maven") {
            from(components["java"])
            artifactId = "fade-animation-android"

            pom {
                name.set("Fade Animation (Android)")
                description.set("跨端动效组件库 Android 端 —— 与 iOS/Web 共享同一套缓动、弹簧、编排模型")
                licenses {
                    license {
                        name.set("MIT")
                    }
                }
            }
        }
    }
    // 示例：发到本地目录仓库，便于验证/离线分发
    repositories {
        maven {
            name = "localDir"
            url = uri(layout.buildDirectory.dir("maven-repo"))
        }
    }
}
