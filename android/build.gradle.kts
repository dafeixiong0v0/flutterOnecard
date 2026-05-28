allprojects {
    repositories {
        maven { url = uri("https://maven.aliyun.com/repository/google") }
        maven { url = uri("https://maven.aliyun.com/repository/public") }
        maven("https://dl.google.com/dl/android/maven2/")
        maven("https://repo1.maven.org/maven2/")
        maven { 
            isAllowInsecureProtocol = true
            url = uri("http://repo-sdk.tange-ai.com/repository/maven-public/")
            credentials { username = "AD_31EKtAvCYsxt7jwVFZsLT4pv5OU"; password = "3b05be4a210d8f06c192b297e015c395" }
        }
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
