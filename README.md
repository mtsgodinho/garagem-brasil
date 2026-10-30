# Garagem Brasil

Protótipo 0.7.0 em **Godot 4.6.3 / GDScript**, renderer **Compatibility**.
A garagem e a personalização foram aprovadas pelo usuário no Windows. O usuário confirmou o salvamento e pediu mais semelhança com fotos reais. Esta entrega revisa **carroceria, materiais, pneus, iluminação e enquadramento**, preservando as personalizações e os saves.

## Abrir no Windows (sem programação)

1. Baixe o Godot **4.6.3 Standard**, para Windows x86_64, no site oficial https://godotengine.org/download/archive/4.6.3-stable/ . Não precisa da edição .NET nem de instalar Blender para executar este protótipo.
2. Extraia o ZIP do Godot e a pasta deste projeto em seu computador.
3. Abra o executável do Godot. No gerenciador de projetos, clique em **Importar**, escolha o arquivo **project.godot** desta pasta e abra o projeto.
4. Aguarde a importação e pressione **F6** com `scenes/garage.tscn` aberta, ou **F5** para executar o projeto.
5. Arraste com o botão esquerdo sobre a cena para girar ao redor do carro. Use a roda do mouse para aproximar/afastar. Pressione **R** ou clique em **Restaurar câmera** para voltar à posição inicial. **Sair** fecha o jogo.

Não há executável Windows exportado nesta entrega. O projeto deve ser executado pelo Godot; exportação e validação do executável pertencem à finalização. Não houve teste em Windows neste ambiente Linux.

## Novidade 0.7.0 — dirigir e fotografar

No rodapé, **Testar carro** abre a estrada de 2,4 km com seu carro personalizado. **W** acelera, **S** freia/dá ré, **A/D** viram, **Espaço** freia, **C** alterna câmera e **ESC** abre o menu. **R** reposiciona. Use **Voltar à garagem** para retornar com suas modificações.

**Modo foto** ou **P** abre a câmera orbital na garagem e na pista. **F12** ou Fotografar salva PNG sem interface; **Abrir pasta** mostra os arquivos, **TAB** oculta os controles e **P/ESC** retorna. Na pista, o carro fica congelado enquanto você fotografa. Fotos no Windows: `%APPDATA%\Godot\app_userdata\Garagem Brasil\photos`.

[Instruções detalhadas e roteiro de teste](docs/PISTA_E_FOTOS.md). A condução é arcade e a pista é simples; a versão nova ainda precisa de teste no Windows. Fotos locais não são enviadas automaticamente ao GitHub.

## Personalização: como usar

O painel à direita tem nove categorias: Pintura, Rodas, Vidros, Aberturas, Motor / som, Interior, Exterior, Adesivos e Suspensão. As mudanças aparecem imediatamente, sem botão de confirmação:

- **Pintura:** clique na amostra grande para escolher qualquer cor, ou em uma das seis cores rápidas. Selecione Brilhante, Metálica ou Fosca e ajuste o brilho.
- **Rodas:** escolha um dos dez desenhos, clique na amostra para mudar a cor e ajuste o aro de 13 a 17 polegadas. As quatro rodas mudam juntas. O diâmetro externo do pneu permanece igual; o perfil muda para acomodar o aro.
- **Vidros:** escolha Sem película, Clara, Média, Escura, Extremamente escura ou Espelhada. O tipo define uma intensidade inicial; o slider permite ajustar. Sem película desativa o slider. A intensidade é apenas visual. A espelhada usa reflexos do ambiente de estúdio e não reflete todos os objetos da garagem.

## Portas, capô, motor, som e interior

- **Aberturas:** ligue/desligue Porta esquerda, Porta direita, Capô ou Porta-malas. Use Abrir tudo / Fechar tudo para controlar as quatro peças. Este hatch provisório tem duas portas laterais.
- **Motor / som:** ative Filtro esportivo, Kit turbo visual e Barra de amarração. As peças aparecem no cofre e o capô abre automaticamente ao trocar uma opção. **Ver motor** também aproxima a câmera.
- Na mesma categoria, role o painel para baixo se necessário e escolha Sem caixa, Compacta (1 subwoofer), Dupla (2) ou Paredão compacto (4 falantes). **Ver porta-malas** abre a tampa e enquadra a traseira.
- **Interior:** escolha Tecido, Couro sintético ou Esportivo bicolor. Há cores independentes para bancos e painel/portas. No bicolor, as laterais dos bancos usam a cor do interior. **Ver interior** abre as portas e aproxima a câmera.
- **Restaurar câmera** ou R retorna à vista geral, inclusive depois de usar os botões de detalhe.

Motor e som são montagens visuais nesta entrega: não alteram potência nem reproduzem áudio. O interior e a geometria continuam simplificados. Ao reabrir o jogo, as peças começam fechadas; as escolhas de acessórios e cores são preservadas.

## Salvamento: como usar

A versão atual mostra **ESTÚDIO 07 / GARAGEM E PISTA** e o botão **Salvar modificações** abaixo das abas.

- Ao parar de alterar uma opção por 0,6 segundo, o jogo salva automaticamente. O rodapé indica alterações pendentes, sucesso ou falha.
- O botão **Salvar modificações** grava imediatamente.
- **Sair** e o X da janela do jogo tentam gravar qualquer alteração pendente antes de fechar. Se falhar, o jogo oferece Voltar ou Sair sem salvar.
- Ao abrir novamente, cor, acabamento, brilho, desenho/cor/aro das rodas, tipo/intensidade da película, peças do motor, caixa de som, estofado e cores do interior são carregados e aparecem tanto no carro quanto nos controles.
- Não precisa de Internet, conta ou banco de dados. A pista de teste está disponível pelo botão Testar carro.

No Windows, os dados ficam em `%APPDATA%\Godot\app_userdata\Garagem Brasil\garagem\customization.json`. Para abrir a pasta, pressione **Win+R**, cole `%APPDATA%\Godot\app_userdata\Garagem Brasil\garagem` e pressione Enter. Não é necessário editar esse arquivo para jogar.

O formato atual (schema 3) lê saves dos schemas 1 e 2, mantendo pintura/rodas/vidros e usando padrões para as novas opções. O jogo mantém `.bak` com a versão válida anterior. Se o principal estiver inválido, tenta esse backup; se ambos forem inválidos, abre com os padrões e mostra um aviso. Arquivos inválidos ou incompatíveis são preservados como `.invalid-<data>.json` antes de uma nova gravação. Falha em preservar ou gravar interrompe o salvamento e mantém o estado pendente.

O arquivo é compartilhado pelas cópias do projeto com o nome Garagem Brasil no mesmo usuário Windows: extrair uma versão nova em outra pasta não deve apagar as escolhas já salvas. As escolhas feitas na versão anterior sem salvamento não podem ser recuperadas automaticamente.

## O que testar para aprovar esta entrega

1. Abra a versão que mostra **ESTÚDIO 07 / GARAGEM E PISTA**.
2. Escolha uma cor diferente, acabamento e brilho; troque modelo, cor e tamanho das rodas; escolha uma película e intensidade.
3. Teste abrir/fechar todas as peças; selecione peças de motor, uma caixa de som, estofado e cores do interior.
4. Clique em **Salvar modificações** e confira a mensagem verde **Modificações salvas neste computador**.
5. Clique em **Sair**; no editor, pressione **F5** novamente.
6. Confira se todas as escolhas voltaram no carro e nas abas, com a mensagem **Modificações carregadas**.
7. Faça outra mudança, espere a confirmação automática e repita Sair/F5 sem clicar em Salvar.

Não use o botão de parada forçada do editor para este teste: ele pode encerrar o processo antes de uma alteração pendente ser gravada. O fluxo de fechamento normal é Sair ou o X da janela do jogo.

Verificações de personalização que continuam disponíveis:

- Trocar pintura e acabamento com o carro visível; experimentar uma cor escura e uma clara.
- Comparar os cinco desenhos de rodas e os aros 13 e 17, girando a câmera para ver os dois lados.
- Trocar a cor das rodas sem alterar a pintura do carro.
- Comparar todos os tipos de película e arrastar a intensidade; verificar interior visível sem película e oculto com película muito escura.
- Arrastar sliders e abrir seletores sem que a câmera gire; girar a câmera arrastando diretamente na cena.
- Conferir se o painel e seus textos cabem na janela do seu computador.

O hatch agora usa uma **malha GLB original de estudo**, criada no Blender com carroceria curva, arcos de roda, faróis com refletores e interior arredondado. A estrutura tem cerca de 3,92 m de comprimento e 1,68 m de largura, sem retrovisores. Não é uma reprodução fiel do Volkswagen Gol G3 e não utiliza modelo pago. Vidros, carroceria, interior simplificado, faróis, lanternas, para-choques, retrovisores e quatro rodas são peças separadas. A fidelidade visual ainda não foi aprovada.

## Tunagem externa 0.6.0

- **Exterior:** para-choques Original, Esportivo ou Touring (dianteiro e traseiro juntos); para-lamas Original, Alargador discreto ou Wide body; kit Sem kit, Saias e lip ou Aero completo. O aerofólio acompanha a tampa traseira.
- **Sinaleiras:** na mesma categoria Exterior, escolha Original, Fumê, Cristal ou Vermelha. São opções visuais, sem simulação elétrica nesta entrega.
- **Adesivos:** faixa lateral, listras duplas no capô/teto ou número 06 nas portas; cor livre. As partes nos painéis móveis acompanham sua abertura. Não há importação de imagens externas nesta versão.
- **Suspensão:** rebaixamento visual de 0 a 6 cm em passos de 0,5 cm. Rodas ficam no piso; a carroceria, motor e peças móveis descem juntos. As aberturas dos para-lamas e caixas internas são ajustadas para preservar espaço para os pneus. Isso é uma aproximação visual, sem suspensão dinâmica ou alteração da física.
- **Rodas:** dez modelos, com cinco novos (rally, multirraios, malha cruzada, três raios e aero). Cor livre e tamanhos 13–17 permanecem disponíveis.
- **Cores:** 18 amostras rápidas na Pintura, além do seletor livre para carroceria, rodas, adesivos e interior. Role dentro do painel para ver opções que não couberem na janela.

Tudo é salvo automaticamente. O schema 3 mantém leitura dos saves anteriores, aplicando padrões às novas opções. Não apague seus arquivos de salvamento ao atualizar.

Os acessórios novos são estudos procedurais próprios; não representam peças reais licenciadas. Para testar: compare cada opção, abra portas/capô/tampa com adesivos e aero, experimente altura 0/3/6 cm e confirme que as escolhas voltam após Sair/F5.

Ideias para as próximas entregas: pista e direção, modo foto, perfis de montagens, faróis/setas funcionais, cambagem/espaçadores, som do motor/escapamento e outros veículos (Celta, Uno, Palio). Pista/direção e modo foto foram posteriormente autorizados e implementados na versão 0.7.0; as outras ideias continuam planejadas.

## Revisão visual 0.5.0

Carroceria, teto, capô e para-lamas usam superfícies curvas; faróis têm carcaça, lente e refletores separados. Para-choques, frisos, retrovisores, volante, painel e bancos foram remodelados. Pneus têm laterais arredondadas e sulcos, com contato ajustado à plataforma. O estúdio usa luz neutra, reflexos de painéis, sombra de contato, microtexturas de 256 px e MSAA 2x em Compatibility.

O modelo continua com **duas portas**, e sua fidelidade ainda precisa de aprovação. A foto prata enviada mostra quatro portas; não foi feita uma conversão para quatro portas nesta etapa. Não é fotorealismo nem digitalização de um veículo real. Os materiais de motor e caixas continuam simplificados.

A nova versão lê o mesmo arquivo de salvamento; não é necessário apagar ou editar seus dados. Confira se as escolhas antigas aparecem e teste as quatro aberturas. A aparência antiga foi preservada no histórico Git e nas imagens da linha do tempo.

Blender é necessário apenas para editar/regenerar a fonte. Veja [a documentação do modelo](assets/vehicles/gol_study/README.md). No Windows, importe a pasta nova e aguarde o Godot importar o GLB antes de pressionar F5.

## Desenvolvimento na nuvem

O ambiente disponível tem Godot 4.6.3 e Blender 4.3.2. Não são necessários pacotes externos para esta entrega. O script abaixo usa diretórios graváveis para os dados do Godot:

```bash
cd /workspace/garagem-brasil
./tools/godot-cloud.sh --headless --editor --import
python3 tools/verify-cloud.py
./tools/godot-cloud.sh --headless --quit-after 120
```

Para editar em um ambiente com display: `./tools/godot-cloud.sh --editor`.
O teste gráfico `tests/render_capture.gd` requer display X11/OpenGL no Linux e grava uma imagem com nome único em `/workspace/.runtime/`; não deve ser usado como comando de execução no Windows.

## Validação e histórico de testes

- Smoke test: cena, grupos de peças, quatro rodas, faces laterais voltadas para fora, câmera, zoom e restauração.
- `tests/customization.gd`: **171 verificações** acionando a interface para cores, acabamentos, cinco geometrias, aros 13–17 nas quatro rodas, presets de película, intensidade, ausência de reconstrução ao trocar cor e isolamento de materiais entre veículos.
- `tests/interaction.gd`: mouse enviado ao viewport real; slider altera o brilho sem girar a câmera, arrasto na cena gira a câmera, soltar sobre interface encerra o arrasto e clique abre o seletor de cores. Executado com display virtual.
- Na etapa 0.2, `tests/render_customization.gd` produziu **15 capturas** OpenGL com cinco rodas, seis películas, pinturas e lados do veículo. Comparação de pixels da região do carro confirmou diferenças de pintura e transparência. Capturas finais arquivadas em [linha do tempo](docs/linha-do-tempo/README.md).
- Testes gráficos executados em Linux / Mesa llvmpipe. O display virtual emite aviso de VSync não suportado. Isso não constitui medição de desempenho em hardware modesto.
- `tests/persistence.gd`: **63 verificações** de serialização completa, backup, arquivo ausente/inválido, validação de tipos/limites/versão, migração de schema 1 para 2, preservação do original e falhas de gravação.
- `tests/accessories.gd`: **54 verificações** de categorias, pivôs, animações e reversão, materiais nas peças móveis, filtros/turbo/barra, quatro opções de caixa, estofados, cores e enquadramento de detalhe.
- Na etapa 0.4, `tests/render_accessories.gd` produziu nove capturas finais das peças fechadas/abertas, motor, três caixas e três estofados; a primeira prévia também foi preservada na linha do tempo.
- `tests/persistence_process.gd`: processos independentes gravaram por autosave, reabriram recuperando todos os campos, fecharam com alteração pendente e reabriram novamente; falha de gravação deixou o estado pendente e mostrou confirmação ao sair.
- Na etapa 0.3, `tests/render_persistence.gd` produziu capturas da interface com sucesso de gravação, carregamento e recuperação de backup.
- `tests/visual_model.gd`: **18 verificações** de grupos GLB, dimensões, coordenadas finitas, contato dos pneus e orçamento de até 120 mil triângulos com rodas/acessórios. O conjunto validado fica abaixo desse limite.
- `tests/render_visual_revision.gd`: vistas reais de frente, lateral, traseira, aro 17, peças abertas, interior, porta-malas e detalhe frontal; prévias também preservadas na linha do tempo.
- `tools/verify-cloud.py`: executa os testes sem tocar no arquivo do jogador, com timeout e detecção de erros de script mesmo quando o Godot retorna código zero.
- Garagem e personalização foram executadas e aprovadas pelo usuário no Windows. O usuário confirmou salvamento e acessórios no Windows. A revisão visual 0.5.0 **ainda precisa do teste do usuário no Windows**.
- A leitura GitHub funciona pela configuração de rede do ambiente; nenhum token foi solicitado.

Consulte [o planejamento e a arquitetura](docs/PLANO.md). A direção arcade está implementada; a exportação de executável ainda está pendente.

Validação 0.6.0: testes de exterior/suspensão (55 verificações), dez rodas, migração de saves antigos e gravação/reabertura de todas as novas escolhas; capturas reais dos kits e adesivos. Executados no Linux; a versão nova ainda precisa do teste no Windows.

Validação 0.7.0: 18 verificações de direção/colisão/pausa/foto/retorno e PNGs reais salvos na pista e garagem. As verificações das etapas anteriores continuam executadas por tools/verify-cloud.py.
