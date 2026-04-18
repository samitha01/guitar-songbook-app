allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
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

subprojects {
    val project = this
    plugins.withType<com.android.build.gradle.api.AndroidBasePlugin> {
        val android = project.extensions.getByName("android")
        try {
            val setNamespace = android.javaClass.getMethod("setNamespace", String::class.java)
            val getNamespace = android.javaClass.getMethod("getNamespace")
            
            if (getNamespace.invoke(android) == null) {
                setNamespace.invoke(android, project.group.toString())
            }
        } catch (e: Exception) {
            // Silently ignore if namespace is already handled
        }
    }
}