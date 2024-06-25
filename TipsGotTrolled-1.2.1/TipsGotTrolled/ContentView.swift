import SwiftUI
import MacDirtyCow
import AbsoluteSolver

struct ContentView: View {
    @State var LogItems: [String.SubSequence] = {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return ["Welcome to TipsGotTrolled v\(version)!", "", "Please press Exploit, allow, then Change Tips", "", "by haxi0 and C22"]
        } else {
            return ["Error getting app version!"]
        }
    }()
    @State var debugMode = true
    @State private var exploited = false
    @AppStorage("patched") var patched = false
    let ts = TS.shared
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Button("Exploit") {
                        do {
                            try MacDirtyCow.unsandbox()
                            exploited = true
                            UIApplication.shared.alert(title: "DirtyCow exploit completed", body: "MacDirtyCow full disk access was ran. Please press the Change Tips button to continue.")
                        } catch {
                            UIApplication.shared.alert(title: "Error", body: "Error: \(error)")
                        }
                    }
                    Button("Change Tips") {
                        do {
                            let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
                            
                            if FileManager.default.fileExists(atPath: documentsDirectoryURL!.appendingPathComponent("Tips").path) {
                                do {
                                    try AbsoluteSolver.delete(at: documentsDirectoryURL!.appendingPathComponent("Tips"))
                                } catch {
                                    UIApplication.shared.alert(title: "Error", body: "Error: \(error)")
                                }
                            }
                            
                            try AbsoluteSolver.copy(at: URL(fileURLWithPath: ts.getTipsPath()!), to: documentsDirectoryURL!.appendingPathComponent("Tips")) // backup previous binary just in case
                            try MacDirtyCow.overwriteFileWithDataImpl(originPath: ts.getTipsPath()!, replacementData: Data(contentsOf: Bundle.main.url(forResource: "PersistenceHelper_Embedded", withExtension: "")!))
                            
                            UIApplication.shared.alert(title: "Done, READ!!!", body: "â ï¸ PLEASE, DO NOT LAUNCH TIPS AFTER INSTALLATION. REBOOT RIGHT NOW, THEN LAUNCH IT! â ï¸", withButton: false)
                        } catch {
                            UIApplication.shared.alert(title: "Error", body: "Error: \(error)")
                        }
                    }
                    .disabled(!exploited)
                } header: {
                    Label("Hijack Tips", systemImage: "hammer")
                }
                Section {
                    HStack {
                        ScrollView {
                            ScrollViewReader { scroll in
                                VStack(alignment: .leading) {
                                    ForEach(0..<LogItems.count, id: \.self) { LogItem in
                                        Text("\(String(LogItems[LogItem]))")
                                            .textSelection(.enabled)
                                            .font(.custom("Menlo", size: 15))
                                    }
                                }
                                .onReceive(NotificationCenter.default.publisher(for: LogStream.shared.reloadNotification)) { obj in
                                    DispatchQueue.global(qos: .utility).async {
                                        FetchLog()
                                        scroll.scrollTo(LogItems.count - 1)
                                    }
                                }
                            }
                        }
                        .frame(width: UIScreen.main.bounds.width - 80, height: 250)
                    }
                    .padding()
                }
            header: {
                Label("Console", systemImage: "bolt")
            }
            footer: {
                Text("Made by C22 and haxi0 with sweat and tears. TrollStore by opa334, method by Alfie. M1 and M2 are also supported.")
            }
            }
            .navigationBarTitle(Text("TipsGotTrolled"), displayMode: .inline)
        }
    }
    
    func FetchLog() {
        guard let AttributedText = LogStream.shared.outputString.copy() as? NSAttributedString else {
            LogItems = ["Error Getting Log!"]
            return
        }
        LogItems = AttributedText.string.split(separator: "\n")
    }
}