# Plano progressivo

## Entrega inicial — estrutura e visualização (aprovada em 30/10/2026)

Godot 4.6.3 Standard, GDScript, Compatibility, unidades em metros, frente do veículo em -Z. Cenário procedural sem texturas externas, janela inicial 1280 × 720 com interface adaptável.

- `scenes/garage.tscn`: entrada do projeto.
- `scripts/garage.gd`: montagem da garagem e interface de visualização.
- `scripts/camera/orbit_camera.gd`: órbita, zoom e restauração independentes do veículo.
- `scripts/vehicles/placeholder_car.gd`: visual provisório substituível.
- `assets/vehicles/`: destino futuro dos modelos GLB/glTF.
- `tests/`: verificações da cena, controles e captura gráfica.

O veículo expõe nós `Body`, `Glass`, `Interior` e `Wheels`; cada roda tem seu próprio nó. A garagem instancia o visual em `VehicleVisual`. Um modelo definitivo deverá manter um adaptador para esses grupos, materiais próprios por instância, origem no chão e escala em metros. Não vincular regras de personalização à triangulação deste modelo provisório.

## Personalização — aprovada pelo usuário em 30/10/2026

- `scripts/customization/vehicle_customization.gd`: Resource com estado da sessão, nomes de opções e presets. Independente da malha e pronto para futura serialização.
- `scripts/ui/customization_panel.gd`: painel de categorias, cor, acabamento, brilho, desenho/aro/cor das rodas e película/intensidade. Emite sinais para a garagem aplicar o estado ao visual.
- `scripts/vehicles/wheel_visual.gd`: fábrica procedural dos cinco desenhos; diâmetro externo preservado, material compartilhado entre as quatro rodas do mesmo veículo. Mudança de cor não recria geometria.
- `apply_customization` no visual: aplica estado a materiais próprios por instância e só reconstrói rodas quando desenho ou aro mudam.
- Ambiente de reflexão do céu de baixa resolução, sem reflection probes dinâmicos ou efeitos pesados.

## Salvamento — confirmado pelo usuário no Windows

- `scripts/persistence/customization_store.gd`: JSON schema 2 (com leitura/migração do schema 1) associado ao veículo, validação estrita de todos os campos e valores, arquivo temporário, backup válido anterior e preservação de originais inválidos/incompatíveis antes de substituir.
- `garage.gd`: carrega antes de montar a interface, aplica ao visual, agenda autosave após 0,6 s sem mudanças, permite gravação manual e tenta gravar ao sair. Em falha, conserva estado pendente e solicita confirmação antes de descartar ao sair.
- `customization_panel.gd`: botão de gravação e mensagens de estado; controles iniciam com dados carregados.
- Os testes usam caminhos isolados ou desativam persistência para não modificar dados reais do jogador. O teste entre processos usa a mesma inicialização da cena do jogo.

O salvamento atual atende um veículo e um usuário local. Próximos veículos exigirão novos identificadores e migração/catálogo; o formato versionado permite evoluir sem usar a cena como arquivo de save. Não há serviço remoto.

Aprovação desta entrega precede implementação de direção.

## Ampliação solicitada — garagem interativa testada no Windows

- `placeholder_car.gd` mantém pivôs independentes de portas esquerda/direita, capô e hatch traseiro; os tweens podem ser invertidos sem reconstruir o carro. Janelas e painéis acompanham seus pivôs e compartilham os materiais de personalização.
- Carroceria recortada para deixar vãos reais, capô com perfil inclinado e molduras próprias da tampa traseira; cofre e porta-malas deixam de depender da silhueta fechada.
- `accessory_visuals.gd` monta peças próprias do motor e três caixas de som; estado define visibilidade das peças e só reconstrói a caixa ao trocar a montagem.
- Estofado/cor dos bancos e cor do interior são materiais independentes; couro usa menor rugosidade e esportivo bicolor usa contraste nas laterais.
- Seis categorias visíveis no painel, controles de aberturas e botões que enquadram motor, porta-malas e interior.
- Schema 2 persiste as novas escolhas; a posição aberta/fechada é transitória e reinicia fechada. Schema 1 é lido com os padrões das novas opções.
- Não implementa potência, física, áudio de caixas, animação de personagens ou modelo definitivo do Gol G3.

## Revisão visual — versão 0.5.0, aguarda aprovação

O usuário confirmou os saves e pediu aparência mais próxima das duas fotografias enviadas. Criamos malha própria GLB em Blender, sem recurso pago, com origem e pivôs compatíveis com os controles existentes. `placeholder_car.gd` agora é o adaptador de materiais/animação do GLB; o nome do arquivo é mantido para não quebrar referências.

As rodas continuam procedurais com pneus arredondados e bitola corrigida. Iluminação neutra, shader de reflexos de estúdio, sombra de contato, MSAA 2x e microtexturas leves substituem a iluminação azulada/chapada. O renderer continua Compatibility; não há ray tracing, SSR ou AO pesado. O desempenho precisa de medição no computador do usuário.

Fonte: `tools/blender/source/gol_study.blend`; gerador: `tools/blender/build_gol_study.py`; recurso de execução: `assets/vehicles/gol_study/gol_study.glb`. O diretório da fonte usa `.gdignore`, portanto Blender não é necessário no Windows para jogar. O modelo permanece estudo aproximado de duas portas, não a reprodução fiel de quatro portas da primeira referência.

## Plano das entregas

1. **Personalização:** recurso `VehicleDefinition` para catálogo e cenas de cada carro; estado `VehicleCustomization` separado do visual; controladores de materiais de carroceria/vidros e catálogo de cinco rodas. Interface lateral em português. Validar mudança visual imediata.
2. **Salvamento:** serialização versionada do estado em `user://`, valores validados, defaults e recuperação de arquivo inválido. Testar reinício e preservação do estado.
3. **Direção:** cena de pista separada, controlador de física separado do visual, mesmo estado aplicado ao entrar/sair. Testar aceleração, freio, ré, direção, câmeras, velocímetro e retorno.
4. **Finalização:** menus completos, configurações de resolução/qualidade, medição em hardware representativo, templates oficiais e exportação Windows. Teste de aceitação no Windows é obrigatório antes de declarar a plataforma validada.

Cada entrega deve ser testada e revisada antes da seguinte. Catálogos de peças por categoria e pontos de montagem no modelo permitirão extensões de exterior, suspensão, mecânica e interior, sem misturar essas regras com a câmera ou o cenário. As opções visuais de motor e interior descritas acima já foram implementadas; as demais extensões continuam planejadas.

## Recursos e limitações

Nenhum recurso pago ou modelo externo foi usado. O modelo definitivo exige geometria própria ou modelo gratuito com licença compatível documentada. Blender está disponível, mas não é dependência de execução. Reflexos de película e desempenho deverão respeitar o renderer Compatibility; não prometer reflexos de ray tracing.
