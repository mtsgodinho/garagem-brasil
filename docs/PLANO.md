# Plano progressivo

## Entrega inicial — estrutura e visualização (aguarda aprovação)

Godot 4.6.3 Standard, GDScript, Compatibility, unidades em metros, frente do veículo em -Z. Cenário procedural sem texturas externas, janela inicial 1280 × 720 com interface adaptável.

- `scenes/garage.tscn`: entrada do projeto.
- `scripts/garage.gd`: montagem da garagem e interface de visualização.
- `scripts/camera/orbit_camera.gd`: órbita, zoom e restauração independentes do veículo.
- `scripts/vehicles/placeholder_car.gd`: visual provisório substituível.
- `assets/vehicles/`: destino futuro dos modelos GLB/glTF.
- `tests/`: verificações da cena, controles e captura gráfica.

O veículo expõe nós `Body`, `Glass`, `Interior` e `Wheels`; cada roda tem seu próprio nó. A garagem instancia o visual em `VehicleVisual`. Um modelo definitivo deverá manter um adaptador para esses grupos, materiais próprios por instância, origem no chão e escala em metros. Não vincular regras de personalização à triangulação deste modelo provisório.

## Próximas entregas, somente após aprovação

1. **Personalização:** recurso `VehicleDefinition` para catálogo e cenas de cada carro; estado `VehicleCustomization` separado do visual; controladores de materiais de carroceria/vidros e catálogo de cinco rodas. Interface lateral em português. Validar mudança visual imediata.
2. **Salvamento:** serialização versionada do estado em `user://`, valores validados, defaults e recuperação de arquivo inválido. Testar reinício e preservação do estado.
3. **Direção:** cena de pista separada, controlador de física separado do visual, mesmo estado aplicado ao entrar/sair. Testar aceleração, freio, ré, direção, câmeras, velocímetro e retorno.
4. **Finalização:** menus completos, configurações de resolução/qualidade, medição em hardware representativo, templates oficiais e exportação Windows. Teste de aceitação no Windows é obrigatório antes de declarar a plataforma validada.

Cada entrega deve ser testada e revisada antes da seguinte. Catálogos de peças por categoria e pontos de montagem no modelo permitirão extensões de exterior, suspensão, mecânica e interior, sem misturar essas regras com a câmera ou o cenário. Essas extensões ainda são planejamento, não funcionalidades implementadas.

## Recursos e limitações

Nenhum recurso pago ou modelo externo foi usado. O modelo definitivo exige geometria própria ou modelo gratuito com licença compatível documentada. Blender está disponível, mas não é dependência de execução. Reflexos de película e desempenho deverão respeitar o renderer Compatibility; não prometer reflexos de ray tracing.
