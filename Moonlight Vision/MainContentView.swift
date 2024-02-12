//

import SwiftUI
import RealityKit

struct MainContentView: View {
    @EnvironmentObject private var viewModel: MainViewModel
    
    @State private var selectedHost: TemporaryHost?
    
    @State private var addingHost = false
    @State private var newHostIp = ""
    @State private var dimPassthrough = true

    var body: some View {
        if viewModel.activelyStreaming {
            ZStack {
                StreamView(streamConfig: $viewModel.currentStreamConfig)
            }
            .onAppear() {
                guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
                let geometryRequest = UIWindowScene.GeometryPreferences.Vision(resizingRestrictions: .uniform)
                windowScene.requestGeometryUpdate(geometryRequest)
            }
            .onDisappear() {
                guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
                let geometryRequest = UIWindowScene.GeometryPreferences.Vision(resizingRestrictions: .freeform)
                windowScene.requestGeometryUpdate(geometryRequest)
            }
            .toolbar {
                
            }
            .ornament(attachmentAnchor: .scene(.topLeading), contentAlignment: .bottomLeading) {
                HStack {
                    Button("Close", systemImage: "xmark") {
                        viewModel.activelyStreaming = false
                    }
                    Button("Toggle Dimming", systemImage: dimPassthrough ? "moon.fill" : "moon") {
                        dimPassthrough.toggle()
                    }
                }
                .labelStyle(.iconOnly)
                .padding()
            }
            .clipShape(RoundedRectangle(cornerRadius: 30.0))
            .glassBackgroundEffect(in: RoundedRectangle(cornerRadius: 30.0))
            .preferredSurroundingsEffect(dimPassthrough ? .systemDark : nil)
        } else {
            TabView {
                NavigationSplitView {
                    List(viewModel.hosts, selection: $selectedHost) { host in
                        NavigationLink(value: host) {
                            Label(host.name, 
                                  systemImage: host.pairState == .paired ? 
                                  "desktopcomputer" : "lock.desktopcomputer")
                                .foregroundColor(.primary)
                        }
                    }
                    .onChange(of: viewModel.hosts) {
                        // If the hosts list changes and no host is selected,
                        // try to select the first paired host automatically.
                        if selectedHost == nil,
                            let firstHost = viewModel.hosts.first(where: { $0.pairState == .paired }) {
                            selectedHost = firstHost
                        }
                    }
                    .navigationTitle("Computers")
                    .toolbar {
                        ToolbarItem(placement: .primaryAction) {
                            Button("Add Server", systemImage: "plus") {
                                addingHost = true
                            }.alert(
                                "Enter server",
                                isPresented: $addingHost
                            ) {
                                TextField("IP or Host", text: $newHostIp)
                                Button("Add") {
                                    addingHost = false
                                    viewModel.manuallyDiscoverHost(hostOrIp: newHostIp)
                                }
                                Button("Cancel", role: .cancel) {
                                    addingHost = false
                                }
                            }.alert(
                                "Unable to add host",
                                isPresented: $viewModel.errorAddingHost
                            ) {
                                Button("Ok", role: .cancel) {
                                    viewModel.errorAddingHost = true
                                }
                            } message: {
                                Text(viewModel.addHostErrorMessage)
                            }
                        }
                    }
                } detail: {
                    if let selectedHost {
                        ComputerView(host: selectedHost)
                    }
                    
                }.tabItem {
                    Label("Computers", systemImage: "desktopcomputer")
                }
                .task {
                    viewModel.loadSavedHosts()
                }
                .onAppear {
                    NotificationCenter.default.addObserver(
                        self,
                        selector: #selector(viewModel.beginRefresh),
                        name: UIApplication.didBecomeActiveNotification,
                        object: nil
                    )
                    viewModel.beginRefresh()
                }.onDisappear {
                    viewModel.stopRefresh()
                    NotificationCenter.default.removeObserver(self)
                }
            
                SettingsView(settings: $viewModel.streamSettings).tabItem {
                    Label("Settings", systemImage: "gear")
                }
                
                ImmersiveViews().tabItem {
                    Label("Immersive", systemImage: "visionpro")
                }
            }
        }
    }
}

#Preview {
    MainContentView().environmentObject(MainViewModel())
}
