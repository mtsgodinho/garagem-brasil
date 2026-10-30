# Garagem Brasil

Protótipo inicial em **Godot 4.6.3 / GDScript**, renderer **Compatibility**.
A garagem inicial foi aprovada pelo usuário após abrir no Windows. Esta entrega adiciona **personalização em tempo real** e aguarda novo teste antes do salvamento e da direção.

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

**As escolhas ainda duram somente durante a sessão. Fechar e abrir o jogo restaura os valores iniciais.** Salvamento será a próxima entrega, após aprovação desta personalização. Ainda não há direção.

## O que testar para aprovar esta entrega

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
./tools/godot-cloud.sh --headless --script tests/smoke.gd
./tools/godot-cloud.sh --headless --script tests/customization.gd
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
- A primeira entrega foi executada pelo usuário no Windows. A personalização desta entrega **ainda precisa do teste do usuário no Windows**.
- A leitura GitHub funciona pela configuração de rede do ambiente; nenhum token foi solicitado.

Consulte [o planejamento e a arquitetura](docs/PLANO.md). Salvamento, direção e exportação de executável ainda não estão implementados.
