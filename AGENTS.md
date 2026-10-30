# Instruções do projeto

- O usuário exige desenvolvimento progressivo. A entrega inicial (garagem e visualização) foi testada no Windows e aprovada em 30/10/2026. A personalização de pintura, rodas e vidros foi aprovada pelo usuário, que autorizou salvamento em 30/10/2026. O usuário ampliou o escopo para portas/capô/porta-malas articulados, peças visuais de motor, caixas de som e interior. A entrega atual inclui esses recursos e salvamento/carregamento local; O usuário confirmou que o salvamento funcionou e pediu semelhança com duas fotos reais do Gol G3. A versão atual usa GLB original gerado no Blender e revisão de materiais/luz; aguardar teste/aprovação dessa aparência antes de direção. Motor e caixas são visuais, sem potência ou áudio real.
- Desde 30/10/2026, manter registro visual para uma futura linha do tempo do jogo em `docs/linha-do-tempo/`.
- Arquivar novas capturas geradas, numeradas, sem sobrescrever imagens anteriores; atualizar o índice com data, marco, origem e versão.
- Para fotos do usuário no chat, só afirmar que o arquivo foi salvo se o original estiver acessível e tiver sido copiado. Se indisponível, registrar a referência e a limitação.
- Não publicar capturas com dados pessoais no GitHub; preservar originais fora da publicação e usar versões recortadas quando disponíveis.

- O jogo não depende de Blender: use o GLB em assets/vehicles/gol_study. Fonte e gerador em tools/blender (ignorado pelo importador). Antes dos testes em checkout novo, executar ./tools/godot-cloud.sh --headless --editor --import. Não apagar saves para mostrar a nova aparência.
