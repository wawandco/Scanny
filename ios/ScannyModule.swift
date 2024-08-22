import ExpoModulesCore

public class ScannyModule: Module {
  public func definition() -> ModuleDefinition {
    Name("Scanny")

    Function("hello") {
      return "Hello world! 👋"
    }
  }
}
