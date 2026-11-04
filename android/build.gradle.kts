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
// O wireguard_flutter_plus compila contra a API 31, mas as dependências dele
// (androidx.appcompat 1.6.1) exigem 33+, e o build de release falha no
// checkReleaseAarMetadata. Sobe o compileSdk dos plugins que estejam abaixo
// do da app (36 no Flutter 3.47). Só afeta a compilação: minSdk e targetSdk
// ficam iguais. Tem de vir antes do evaluationDependsOn(":app").
val pluginMinCompileSdk = 36
subprojects {
    if (name != "app") {
        val raiseCompileSdk = {
            extensions.findByName("android")?.withGroovyBuilder {
                val current = getProperty("compileSdk") as Int?
                if (current == null || current < pluginMinCompileSdk) {
                    setProperty("compileSdk", pluginMinCompileSdk)
                }
            }
        }
        if (state.executed) raiseCompileSdk() else afterEvaluate { raiseCompileSdk() }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
