# Estudo visual do Gol G3 — versão 0.5.0

Malha original criada neste projeto com Blender 4.3.2, usando as fotos enviadas pelo usuário apenas como referência visual. Nenhuma malha paga ou externa foi usada. O carro continua sendo um estudo aproximado de duas portas, não uma reprodução fiel do Gol G3 de quatro portas da foto prata.

- `gol_study.glb`: recurso de execução com carroceria curva, vãos e peças móveis, faróis com refletores, para-choques, vidros e interior separado.
- Fonte editável: `tools/blender/source/gol_study.blend`.
- Gerador reproduzível: `tools/blender/build_gol_study.py`.
- Os grupos Body, Glass, Interior, LeftDoor, RightDoor, Hood e Hatch preservam o contrato do adaptador. Pintura, vidros e estofados usam materiais por instância.
- Rodas, motor e caixas de som continuam montados pelo Godot; a malha GLB não fixa as escolhas do jogador.
- O jogo usa somente o GLB: o usuário não precisa instalar Blender. O arquivo fonte está em uma pasta com `.gdignore` para impedir importação automática pelo Godot.

Para regenerar na raiz do projeto:

```bash
blender --background --threads 2 --python tools/blender/build_gol_study.py
./tools/godot-cloud.sh --headless --editor --import
```

As dimensões e materiais são aproximações visuais. Não foi feita digitalização ou medição de um veículo real.
