plugins {
    kotlin("jvm") version "2.1.10"
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
