# Garagem Brasil

Protótipo inicial em **Godot 4.6.3 / GDScript**, renderer **Compatibility**.
A garagem e a personalização foram aprovadas pelo usuário no Windows. Esta entrega adiciona **salvamento e carregamento local** e aguarda novo teste antes da direção.

## Abrir no Windows (sem programação)

1. Baixe o Godot **4.6.3 Standard**, para Windows x86_64, no site oficial https://godotengine.org/download/archive/4.6.3-stable/ . Não precisa da edição .NET nem de instalar Blender para executar este protótipo.
2. Extraia o ZIP do Godot e a pasta deste projeto em seu computador.
3. Abra o executável do Godot. No gerenciador de projetos, clique em **Importar**, escolha o arquivo **project.godot** desta pasta e abra o projeto.
4. Aguarde a importação e pressione **F6** com `scenes/garage.tscn` aberta, ou **F5** para executar o projeto.
5. Arraste com o botão esquerdo sobre a cena para girar ao redor do carro. Use a roda do mouse para aproximar/afastar. Pressione **R** ou clique em **Restaurar câmera** para voltar à posição inicial. **Sair** fecha o jogo.

Não há executável Windows exportado nesta entrega. O projeto deve ser executado pelo Godot; exportação e validação do executável pertencem à finalização. Não houve teste em Windows neste ambiente Linux.

## Personalização: como usar

O painel à direita tem três abas. As mudanças aparecem imediatamente, sem botão de confirmação:

- **Pintura:** clique na amostra grande para escolher qualquer cor, ou em uma das seis cores rápidas. Selecione Brilhante, Metálica ou Fosca e ajuste o brilho.
- **Rodas:** escolha um dos cinco desenhos, clique na amostra para mudar a cor e ajuste o aro de 13 a 17 polegadas. As quatro rodas mudam juntas. O diâmetro externo do pneu permanece igual; o perfil muda para acomodar o aro.
- **Vidros:** escolha Sem película, Clara, Média, Escura, Extremamente escura ou Espelhada. O tipo define uma intensidade inicial; o slider permite ajustar. Sem película desativa o slider. A intensidade é apenas visual. A espelhada usa reflexos do céu e não reflete todos os objetos da garagem.

## Salvamento: como usar

A versão atual mostra **ESTÚDIO 03 / SALVAMENTO** e o botão **Salvar modificações** abaixo das abas.

- Ao parar de alterar uma opção por 0,6 segundo, o jogo salva automaticamente. O rodapé indica alterações pendentes, sucesso ou falha.
- O botão **Salvar modificações** grava imediatamente.
- **Sair** e o X da janela do jogo tentam gravar qualquer alteração pendente antes de fechar. Se falhar, o jogo oferece Voltar ou Sair sem salvar.
- Ao abrir novamente, cor, acabamento, brilho, desenho/cor/aro das rodas e tipo/intensidade da película são carregados e aparecem tanto no carro quanto nos controles.
- Não precisa de Internet, conta ou banco de dados. Ainda não há direção.

No Windows, os dados ficam em `%APPDATA%\Godot\app_userdata\Garagem Brasil\garagem\customization.json`. Para abrir a pasta, pressione **Win+R**, cole `%APPDATA%\Godot\app_userdata\Garagem Brasil\garagem` e pressione Enter. Não é necessário editar esse arquivo para jogar.

O jogo mantém `.bak` com a versão válida anterior. Se o principal estiver inválido, tenta esse backup; se ambos forem inválidos, abre com os padrões e mostra um aviso. Arquivos inválidos ou incompatíveis são preservados como `.invalid-<data>.json` antes de uma nova gravação. Falha em preservar ou gravar interrompe o salvamento e mantém o estado pendente.

O arquivo é compartilhado pelas cópias do projeto com o nome Garagem Brasil no mesmo usuário Windows: extrair uma versão nova em outra pasta não deve apagar as escolhas já salvas. As escolhas feitas na versão anterior sem salvamento não podem ser recuperadas automaticamente.

## O que testar para aprovar esta entrega

1. Abra a versão que mostra **ESTÚDIO 03 / SALVAMENTO**.
2. Escolha uma cor diferente, acabamento e brilho; troque modelo, cor e tamanho das rodas; escolha uma película e intensidade.
3. Clique em **Salvar modificações** e confira a mensagem verde **Modificações salvas neste computador**.
4. Clique em **Sair**; no editor, pressione **F5** novamente.
5. Confira se todas as escolhas voltaram no carro e nas abas, com a mensagem **Modificações carregadas**.
6. Faça outra mudança, espere a confirmação automática e repita Sair/F5 sem clicar em Salvar.

Não use o botão de parada forçada do editor para este teste: ele pode encerrar o processo antes de uma alteração pendente ser gravada. O fluxo de fechamento normal é Sair ou o X da janela do jogo.

Verificações de personalização que continuam disponíveis:

- Trocar pintura e acabamento com o carro visível; experimentar uma cor escura e uma clara.
- Comparar os cinco desenhos de rodas e os aros 13 e 17, girando a câmera para ver os dois lados.
- Trocar a cor das rodas sem alterar a pintura do carro.
- Comparar todos os tipos de película e arrastar a intensidade; verificar interior visível sem película e oculto com película muito escura.
- Arrastar sliders e abrir seletores sem que a câmera gire; girar a câmera arrastando diretamente na cena.
- Conferir se o painel e seus textos cabem na janela do seu computador.

O hatch é um **modelo procedural provisório**, com dimensões aproximadas de 3,92 × 1,64 m. Não é uma reprodução fiel do Volkswagen Gol G3 e não utiliza modelo pago. Vidros, carroceria, interior simplificado, faróis, lanternas, para-choques, retrovisores e quatro rodas são peças separadas. A fidelidade visual ainda não foi aprovada.

## Desenvolvimento na nuvem

O ambiente disponível tem Godot 4.6.3 e Blender 4.3.2. Não são necessários pacotes externos para esta entrega. O script abaixo usa diretórios graváveis para os dados do Godot:

```bash
cd /workspace/garagem-brasil
python3 tools/verify-cloud.py
./tools/godot-cloud.sh --headless --quit-after 120
```

Para editar em um ambiente com display: `./tools/godot-cloud.sh --editor`.
O teste gráfico `tests/render_capture.gd` requer display X11/OpenGL no Linux e grava uma imagem com nome único em `/workspace/.runtime/`; não deve ser usado como comando de execução no Windows.

## Validação desta entrega

- Smoke test: cena, grupos de peças, quatro rodas, faces laterais voltadas para fora, câmera, zoom e restauração.
- `tests/customization.gd`: **131 verificações** acionando a interface para cores, acabamentos, cinco geometrias, aros 13–17 nas quatro rodas, presets de película, intensidade, ausência de reconstrução ao trocar cor e isolamento de materiais entre veículos.
- `tests/interaction.gd`: mouse enviado ao viewport real; slider altera o brilho sem girar a câmera, arrasto na cena gira a câmera, soltar sobre interface encerra o arrasto e clique abre o seletor de cores. Executado com display virtual.
- `tests/render_customization.gd`: **15 capturas** OpenGL com cinco rodas, seis películas, pinturas e lados do veículo. Comparação de pixels da região do carro confirmou diferenças de pintura e transparência. Capturas finais arquivadas em [linha do tempo](docs/linha-do-tempo/README.md).
- Testes gráficos executados em Linux / Mesa llvmpipe. O display virtual emite aviso de VSync não suportado. Isso não constitui medição de desempenho em hardware modesto.
- `tests/persistence.gd`: **48 verificações** de serialização completa, backup, arquivo ausente/inválido, validação de tipos/limites/versão, preservação do original e falhas de gravação.
- `tests/persistence_process.gd`: processos independentes gravaram por autosave, reabriram recuperando todos os campos, fecharam com alteração pendente e reabriram novamente; falha de gravação deixou o estado pendente e mostrou confirmação ao sair.
- `tests/render_persistence.gd`: capturas da interface com sucesso de gravação, carregamento e recuperação de backup.
- `tools/verify-cloud.py`: executa os testes sem tocar no arquivo do jogador, com timeout e detecção de erros de script mesmo quando o Godot retorna código zero.
- Garagem e personalização foram executadas e aprovadas pelo usuário no Windows. O salvamento desta entrega **ainda precisa do teste do usuário no Windows**.
- A leitura GitHub funciona pela configuração de rede do ambiente; nenhum token foi solicitado.

Consulte [o planejamento e a arquitetura](docs/PLANO.md). Direção e exportação de executável ainda não estão implementadas.
