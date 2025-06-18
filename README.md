# 🧠 PrivateAI – Cliente Chat Gemini 2.5 Flash para macOS

**PrivateAI** é um cliente de chat nativo para macOS que integra o modelo **Gemini 2.5 Flash**. Ele oferece uma experiência completa de conversa com IA, incluindo múltiplas sessões, upload de PDF e áudio, histórico persistente e muito mais — tudo diretamente do seu desktop.

> ⚠️ **Atenção:** A chave da API está hard-coded **apenas para fins de testes locais**. Para uso em produção, recomenda-se utilizar `Secrets` ou variáveis de ambiente.

---

## 🚀 Recursos

- ✅ Interface nativa em SwiftUI
- ✅ Múltiplos chats simultâneos com histórico
- ✅ Envio e transcrição de **áudio**
- ✅ Leitura e análise de **PDFs**
- ✅ Integração com **Gemini 2.5 Flash**
- ✅ Armazenamento local do histórico de conversas
- ✅ Suporte completo a macOS Sonoma (14+) com Xcode 16+

---

## 📦 Instalação

1. **Requisitos:**
   - macOS 14 ou superior
   - Xcode 16+
   - Swift 5.10

2. **Clone o repositório:**

   ```bash
   git clone https://github.com/seu-usuario/privateai.git
   cd privateai
   ```

3. **Abra o projeto no Xcode:**

   ```bash
   open PrivateAI.xcodeproj
   ```

4. **No arquivo `Info.plist`, adicione as permissões:**

   ```xml
   <key>NSDocumentsFolderUsageDescription</key>
   <string>Precisamos acessar PDFs escolhidos por você.</string>
   <key>NSSpeechRecognitionUsageDescription</key>
   <string>Precisamos transcrever o áudio que você selecionar.</string>
   ```

5. **Execute o projeto (Cmd + R)**

---

## 🧪 Uso

- Abra o app e comece uma nova conversa.
- Use os botões para:
  - 📄 Enviar arquivos PDF
  - 🎙️ Enviar áudios para transcrição
- Visualize e gerencie sessões anteriores no histórico.

---

## 🔒 Roadmap & Futuro

Nas próximas versões:

- **Execução 100% local com modelos embarcados** (sem dependência de APIs externas)
- **Suporte opcional à execução na nuvem** via Gemini ou outros provedores
- Melhorias na privacidade e uso offline
- Suporte a outros formatos de documentos e transcrição

---

## ⚠️ Aviso de Segurança

A chave da API está embutida **apenas para testes locais**. Para distribuição ou uso real:

- Substitua por um mecanismo seguro de gerenciamento de credenciais.
- Utilize variáveis de ambiente ou o sistema de `Secrets` do Xcode.

---

## 📄 Licença

Este projeto é distribuído sob a licença MIT.
