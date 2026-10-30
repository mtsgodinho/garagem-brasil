# Pista e modo foto — versão 0.7.0

## Testar no Windows

1. Abra a versão que mostra **ESTÚDIO 07 / GARAGEM E PISTA**.
2. Personalize o Gol como quiser e clique em **Testar carro**, no rodapé.
3. Clique dentro da janela do jogo para os controles receberem o teclado.
4. Use **W** para acelerar progressivamente; **S** freia e, depois de parar, engata ré. **A/D** viram e **Espaço** aciona o freio de mão.
5. **C** alterna entre câmera de acompanhamento e câmera de capô. **R** reposiciona o carro no início.
6. **ESC** abre/fecha o menu de pausa. Escolha **Voltar à garagem** no menu ou na barra superior. As modificações devem continuar iguais.
7. Volte à pista novamente para conferir que a transição pode ser repetida.

A estrada tem 2,4 km, faixas, acostamento, árvores e barreiras laterais/nas extremidades. Velocímetro em km/h, limite de projeto de 126 km/h e ré limitada a aproximadamente 29 km/h. O cenário é simples e os controles são arcade: modelo cinemático de bicicleta com gravidade e colisões, sem simulação detalhada de pneus, suspensão dinâmica, dano ou potência dos kits visuais. Fora do asfalto há maior resistência ao movimento.

O carro de teste recebe a mesma Resource de personalização usada na garagem, mas uma instância visual independente. Todas as peças começam fechadas. A geometria de rodas/rebaixamento/cores/adesivos/peças é reaplicada ao entrar. Voltar não lê um save antigo por cima da sessão. Alteração pendente é gravada antes de entrar; se falhar, o jogo permanece na garagem e informa a falha.

## Fotografar

1. Na garagem, clique em **Modo foto** ou pressione **P**. Na pista, use o botão ou P.
2. Arraste com o botão esquerdo para girar e use a rodinha para zoom. **R** restaura o enquadramento em torno do carro.
3. **TAB** oculta/mostra os controles de foto.
4. Clique em **Fotografar** ou pressione **F12**. O PNG é gravado **sem interface**, mesmo quando os controles estão visíveis na tela.
5. Clique em **Abrir pasta** para localizar os arquivos. Eles ficam em `%APPDATA%\Godot\app_userdata\Garagem Brasil\photos` no Windows. Também é possível abrir esse caminho com **Win+R**.
6. **P** ou **ESC** sai do modo foto. Na pista, o carro fica congelado enquanto você fotografa e retoma o estado anterior ao sair; uma pista pausada continua pausada.

As fotos ficam no seu computador e não são enviadas automaticamente ao GitHub. Não sobrescrevemos arquivos existentes. As capturas de desenvolvimento feitas no ambiente Linux são arquivadas separadamente em `docs/linha-do-tempo`.

## Arquitetura e validação

- `scripts/driving/test_track.gd`: cenário de pista, céu/luz, HUD, pausa, câmeras e sinal de retorno. Árvores e faixas usam MultiMesh para reduzir chamadas de desenho.
- `scripts/driving/vehicle_driver.gd`: CharacterBody3D, colisão, gravidade, aceleração, frenagem/ré, direção, freio de mão e rotação das rodas. Controle separado do visual.
- `scripts/photo/photo_mode.gd`: câmera orbital independente, visibilidade do HUD, captura do viewport e restauração da câmera anterior.
- `garage.gd`: preserva a sessão e troca ambiente/câmeras/visibilidade sem descarregar o estado de personalização.
- `tests/driving.gd`: 18 verificações executando física real, barreira de fim da pista, controles, pausa, cores/rodas/altura, foto congelada, retorno, ambiente e segunda entrada.
- `tests/render_driving.gd`: renderização real de garagem/pista/velocímetro/câmeras/menu/foto/retorno e gravação de PNGs sem interface na pista e na garagem.

Testado em Godot 4.6.3 no Linux. A execução desta versão e o botão de abrir pasta ainda precisam do teste do usuário no Windows. O desempenho não foi medido em hardware modesto. Não há executável exportado; usar Godot/F5 como nas versões anteriores.
