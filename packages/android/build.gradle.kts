import org.gradle.api.artifacts.transform.InputArtifact
import org.gradle.api.artifacts.transform.TransformAction
import org.gradle.api.artifacts.transform.TransformOutputs
import org.gradle.api.artifacts.transform.TransformParameters
import org.gradle.api.artifacts.type.ArtifactTypeDefinition.ARTIFACT_TYPE_ATTRIBUTE
import org.gradle.api.file.FileSystemLocation
import org.gradle.api.provider.Provider
import org.gradle.api.tasks.PathSensitive
import org.gradle.api.tasks.PathSensitivity
import java.util.jar.JarOutputStream
import java.util.zip.ZipFile

plugins {
    kotlin("jvm") version "2.1.10"
    `maven-publish`
}

group = "com.fadeanimation"
version = "0.3.0"

// 本模块是 kotlin("jvm") 库，没有 Android Gradle Plugin，默认无法消费 AAR。
// Robolectric 运行时依赖 androidx.test:monitor 等 AAR，注册一个 aar→classes.jar 的
// artifact transform，让 Gradle 自动把 AAR 里的 classes.jar 提取上 classpath(本地/CI 通用)。
abstract class ExtractAarClasses : TransformAction<TransformParameters.None> {
    @get:InputArtifact
    @get:PathSensitive(PathSensitivity.NONE)
    abstract val inputArtifact: Provider<FileSystemLocation>

    override fun transform(outputs: TransformOutputs) {
        val aar = inputArtifact.get().asFile
        val outFile = outputs.file(aar.nameWithoutExtension + "-classes.jar")
        ZipFile(aar).use { zip ->
            val entry = zip.getEntry("classes.jar")
            if (entry != null) {
                outFile.outputStream().use { os -> zip.getInputStream(entry).copyTo(os) }
            } else {
                JarOutputStream(outFile.outputStream()).close()
            }
        }
    }
}

repositories {
    mavenCentral()
    google()
}

dependencies {
    // 注册 AAR → classes.jar 提取转换(供 Robolectric 的 androidx.test AAR 依赖使用)
    registerTransform(ExtractAarClasses::class) {
        from.attribute(ARTIFACT_TYPE_ATTRIBUTE, "aar")
        to.attribute(ARTIFACT_TYPE_ATTRIBUTE, "jar")
    }

    compileOnly("org.robolectric:android-all:14-robolectric-10818077")
    compileOnly("androidx.annotation:annotation:1.7.1")

    testImplementation(platform("org.junit:junit-bom:5.10.2"))
    testImplementation("org.junit.jupiter:junit-jupiter")
    testImplementation("net.jqwik:jqwik:1.8.3")
    testImplementation("org.mockito:mockito-core:5.11.0")
    testImplementation("org.robolectric:android-all:14-robolectric-10818077")
    testRuntimeOnly("org.junit.platform:junit-platform-launcher")

    // Robolectric 运行时：在纯 JVM 下加载真实 Android framework，跑 View 组件冒烟测试。
    // Robolectric 的 runner 基于 JUnit4，通过 junit-vintage-engine 跑在 JUnit5 platform 上，
    // 与现有 jupiter 逻辑测试共存。
    testImplementation("org.robolectric:robolectric:4.12.2") {
        // 排除 158MB 的 native 图形运行时；改用 LEGACY 图形模式(纯 Java shadow)，
        // 冒烟测试只需 View 能实例化/绘制不崩，无需真实像素渲染。
        exclude(group = "org.robolectric", module = "nativeruntime")
    }
    testImplementation("junit:junit:4.13.2")
    testRuntimeOnly("org.junit.vintage:junit-vintage-engine")
}

// 让 test classpath 请求 artifactType=jar，从而触发上面的 aar→classes.jar transform。
listOf("testCompileClasspath", "testRuntimeClasspath").forEach { cfgName ->
    configurations.named(cfgName).configure {
        attributes.attribute(ARTIFACT_TYPE_ATTRIBUTE, "jar")
    }
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
// 产物坐标：com.fadeanimation:fade-animation-android:0.3.0
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
