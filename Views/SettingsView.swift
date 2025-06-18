
import SwiftUI

struct SettingsView: View {
    @AppStorage("customApiKey") private var customApiKey: String = ""
    @AppStorage("modelID") private var modelID: String = "gemini-1.5-flash-latest"
    @AppStorage("appearance") private var appearance: Appearance = .system

    @EnvironmentObject var viewModel: ChatViewModel

    private let models = ["gemini-1.5-flash-latest", "gemini-1.5-pro-latest"]

    var body: some View {
        Form {
            Section("Autenticação") {
                SecureField("Cole sua chave para customizar (opcional)", text: $customApiKey)
                    .textFieldStyle(.roundedBorder)
                Text("Se este campo for deixado em branco, o aplicativo usará uma chave de API padrão.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("Modelo de IA") {
                Picker("Modelo Gemini", selection: $modelID) {
                    ForEach(models, id: \.self) { model in
                        Text(model).tag(model)
                    }
                }
                .pickerStyle(.menu)
            }

            Section("Aparência") {
                Picker("Tema do Aplicativo", selection: $appearance.animation(.easeInOut(duration: 0.4))) {
                    ForEach(Appearance.allCases) { theme in
                        Text(theme.displayName).tag(theme)
                    }
                }
                .pickerStyle(.segmented)
            }

            Section("Gerenciamento de Dados") {
                Button("Apagar Todo o Histórico de Chats", role: .destructive) {
                    viewModel.deleteAllSessions()
                }
            }
        }
        .padding()
        .frame(width: 480, height: 290)
        .navigationTitle("Ajustes")
    }
}
