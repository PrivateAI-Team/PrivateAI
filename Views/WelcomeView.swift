
import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var viewModel: ChatViewModel

    var body: some View {
        ZStack {
            Theme.welcomeGradient
            VStack {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 80))
                    .foregroundStyle(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                Text("PrivateAI").font(.largeTitle.bold()).padding(.top, 10)

                if !viewModel.isApiKeyConfigured {
                    ContentUnavailableView(
                        "Chave de API Inválida ou Faltando",
                        systemImage: "key.fill",
                        description: Text("Por favor, adicione uma chave de API válida nos ajustes do aplicativo para começar.")
                    )
                    Button("Abrir Ajustes") {
                        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
                    }
                } else {
                    Text("Selecione um chat no histórico ou crie um novo para começar.")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
