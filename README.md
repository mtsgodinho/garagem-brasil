# Garagem Brasil

Protótipo inicial em **Godot 4.6.3 / GDScript**, renderer **Compatibility**.
Esta entrega contém somente estrutura, garagem e visualização. Aguarda teste e aprovação do usuário antes da personalização.

## Abrir no Windows (sem programação)

1. Baixe o Godot **4.6.3 Standard**, para Windows x86_64, no site oficial https://godotengine.org/download/archive/4.6.3-stable/ . Não precisa da edição .NET nem de instalar Blender para executar este protótipo.
2. Extraia o ZIP do Godot e a pasta deste projeto em seu computador.
3. Abra o executável do Godot. No gerenciador de projetos, clique em **Importar**, escolha o arquivo **project.godot** desta pasta e abra o projeto.
4. Aguarde a importação e pressione **F6** com `scenes/garage.tscn` aberta, ou **F5** para executar o projeto.
5. Arraste com o botão esquerdo sobre a cena para girar ao redor do carro. Use a roda do mouse para aproximar/afastar. Pressione **R** ou clique em **Restaurar câmera** para voltar à posição inicial. **Sair** fecha o jogo.

Não há executável Windows exportado nesta entrega. O projeto deve ser executado pelo Godot; exportação e validação do executável pertencem à finalização. Não houve teste em Windows neste ambiente Linux.

## O que testar para aprovar esta entrega

- A garagem abre com plataforma, iluminação, piso e veículo visível?
- É possível examinar os dois lados, a frente e a traseira girando 360°?
- O zoom funciona com limites, sem atravessar o centro do carro?
- Restaurar câmera e Sair funcionam?
- A navegação é confortável e a janela funciona no seu computador?

O hatch é um **modelo procedural provisório**, com dimensões aproximadas de 3,92 × 1,64 m. Não é uma reprodução fiel do Volkswagen Gol G3 e não utiliza modelo pago. Vidros, carroceria, interior simplificado, faróis, lanternas, para-choques, retrovisores e quatro rodas são peças separadas. A fidelidade visual ainda não foi aprovada.

## Desenvolvimento na nuvem

O ambiente disponível tem Godot 4.6.3 e Blender 4.3.2. Não são necessários pacotes externos para esta entrega. O script abaixo usa diretórios graváveis para os dados do Godot:

```bash
cd /workspace/garagem-brasil
./tools/godot-cloud.sh --headless --script tests/smoke.gd
./tools/godot-cloud.sh --headless --quit-after 120
```

Para editar em um ambiente com display: `./tools/godot-cloud.sh --editor`.
O teste gráfico `tests/render_capture.gd` requer display X11/OpenGL no Linux e grava `/workspace/.runtime/garage.png`; não deve ser usado como comando de execução no Windows.

## Validação desta entrega

- Teste automatizado em Godot: instanciação da cena, grupos de peças, quatro rodas, arrasto da câmera, fim de arrasto, zoom limitado, órbita e restauração.
- Captura real da cena com OpenGL Compatibility em display virtual Linux / Mesa llvmpipe. Imagem inspecionada e orientação de faces e letreiro corrigida.
- O display virtual emite aviso de VSync não suportado. Isso não constitui teste de desempenho em hardware modesto.
- Não validados: execução Windows, desempenho em máquina real, interação humana e aprovação estética.
- A leitura remota Git falhou por indisponibilidade do proxy local; o checkout local foi usado e nenhum token foi solicitado.

Consulte [o planejamento e a arquitetura](docs/PLANO.md). Pintura, troca de rodas, película, salvamento, direção e exportação ainda não estão implementados.
