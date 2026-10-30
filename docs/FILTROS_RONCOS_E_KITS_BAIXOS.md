# Filtros, roncos e peças baixas — versão 0.8.0

A versão atual mostra **ESTÚDIO 08 / PISTA E RONCOS** e inclui também a pista e o modo foto descritos em [PISTA_E_FOTOS.md](PISTA_E_FOTOS.md).

## Filtros e roncos

Na categoria **Motor / som**, role o painel para baixo e localize **Modelo de filtro**:

- Original: caixa de ar original.
- Cônico esportivo: filtro exposto.
- Duplo fluxo: duas unidades expostas.
- Admissão fria: caixa fechada própria.

O controle antigo Filtro esportivo continua como atalho entre original e cônico. Trocar o modelo sincroniza o atalho. Saves anteriores com filtro esportivo ativo carregam o modelo cônico.

Em **Ronco do motor**, escolha **Automático pelo filtro**, Original suave, Grave encorpado, Esportivo agudo ou Turbo/assobio. Automático usa original suave com a caixa original, esportivo com o cônico e grave com duplo fluxo/admissão fria; com kit turbo instalado, prioriza o ronco turbo. A escolha manual permite comparar os timbres independentemente do filtro.

Ajuste o volume de 0 a 100%. Para escutar antes de dirigir, ligue **Ouvir prévia** na garagem; segure **W** para aumentar a rotação da prévia. Desligar a opção ou colocar volume zero silencia a prévia. Ao entrar na pista, a prévia é desligada e o motor do carro de teste passa a variar com aceleração, velocidade e faixas de marcha. Pausa e modo foto silenciam o motor gradualmente; não há música/áudio das caixas de som nesta entrega.

Os roncos são **sintetizados**, não gravações reais de um Gol. Não foram usados arquivos pagos ou gravações externas. Filtros e kits turbo continuam sem alterar potência/física. O mapa de som por filtro é uma escolha artística para o jogo, não uma medição acústica de peças reais.

## Dianteiro, traseiro e saia independentes

Na categoria **Exterior**, o conjunto anterior continua disponível. As novas opções **Para-choque dianteiro** e **Para-choque traseiro** podem usar o conjunto ou escolher Original, Esportivo, Touring ou **Baixo • arrasta no chão** individualmente.

**Saia lateral** pode usar o body kit, ficar sem saia, usar a esportiva ou **Baixa • arrasta no chão**. As escolhas individuais têm prioridade sobre conjunto/kit.

As peças baixas ajustam sua borda inferior para chegar ao nível do piso em qualquer regulagem de rebaixamento entre 0 e 6 cm. Isso é contato **visual**. Não há atrito específico do body kit, desgaste, faíscas, dano ou simulação física de raspagem. As peças são estudos próprios procedurais, não réplicas de produtos reais.

## Salvamento e testes

Schema 4 persiste filtro, ronco, volume e as três opções independentes, mantendo leitura de schemas 1–3. Não apague o save ao atualizar. A prévia ligada/desligada é temporária; filtros, volume, perfil e peças escolhidas são preservados.

Teste recomendado no Windows:

1. Compare os quatro filtros com o capô aberto e a prévia sonora ligada.
2. Teste os quatro roncos manuais, Automático e volume zero.
3. Entre na pista, acelere/freie e confira a mudança de rotação; pause e entre no modo foto para verificar silêncio.
4. Escolha peças baixas independentemente e compare 0/3/6 cm de rebaixamento.
5. Clique em Salvar modificações, Sair e F5; confira filtros, perfil, volume e peças.

Validação Linux: `tests/sound_and_low.gd` fez 55 verificações de sincronização de filtros, seleção automática/manual, volume zero, contato geométrico com o piso, independência/migração/roundtrip e quatro ondas diferentes com amostras finitas sem exceder o limite. Exportou WAVs de teste de 1 segundo por perfil. `tests/persistence_process.gd` reabriu o jogo em outro processo com os novos campos. Isso não substitui um teste auditivo no Windows: o ambiente de teste usa driver de áudio Dummy.
