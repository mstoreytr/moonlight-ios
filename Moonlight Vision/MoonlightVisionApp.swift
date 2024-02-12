//

import SwiftUI
import RealityKit
import RealityKitContent

struct MoonlightVisionApp: SwiftUI.App {
    @SwiftUI.UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some SwiftUI.Scene {
        WindowGroup {
            MainContentView()
                .environmentObject(appDelegate.mainViewModel)
        }.windowResizability(.contentSize)

        ImmersiveSpace(id: "immersive-space") {
            RealityView { content in
                do {
                    let entity = try await Entity(named: "test_cyber", in: RealityKitContent.realityKitContentBundle)
                    // If model has animations, start them
                    let animation = entity.availableAnimations[0]
                    entity.playAnimation(animation.repeat(duration: .infinity))

                    entity.scale = SIMD3<Float>(1, 1, 1)
                    
                    // needed to center the test file
                    entity.setPosition(SIMD3<Float>(x: 300, y: -10, z: 0), relativeTo: nil)
                    
                    content.add(entity)
                 } catch {
                    print("immersive missing")
                }
            
            }
        }.immersionStyle(selection: .constant(.mixed), in: .mixed)

    }

}

@main
struct MainWrapper {
    static func main() -> Void {
        SDLMainWrapper.setMainReady();
        MoonlightVisionApp.main()
    }
}
