# Oficina e caminho para um jogo de corrida

## Disponível na versão 0.10.0

Oficina cenográfica com ferramentas e móveis; menu e configurações de tela/qualidade/volume; pista arcade com preparação de motor, nitro, danos e reparo. Cor, rodas, películas e peças continuam disponíveis. Preparações e reparos são gratuitos nesta fase.

Preparações em carro íntegro: Original até 126 km/h, Rua até 144, Esportivo até 162, Competição até 180. São limites do controlador, não promessa de velocidade imediata. Aceleração diminui perto do limite. Nitro acrescenta aceleração e até 36 km/h ao limite enquanto há carga; consome 20 pontos por segundo, sem regeneração passiva. Reparo recarrega a carga inteira.

Danos consideram impacto normal às barreiras acima de 2 m/s, com intervalo de proteção de 0,5 s para não cobrar o mesmo contato em todo quadro. Estado reduz limite e aceleração; zero impede acelerar e dar ré. Amassado e riscos são uma representação simples no capô, mesmo para impactos laterais/traseiros; não há deformação física completa, peças soltas ou dano por raspagem. Reparo só ocorre parado na pista; na garagem fica na aba Desempenho. Reposicionar não restaura estado/carga.

Oficina: objetos próprios procedurais sem interação/collisionamento, fora da plataforma; geometria agrupada por material. Pode ver os cantos girando a câmera ou usando modo foto. Não inclui personagem caminhando nem mecânico animado.

Save schema 5: preparação, instalação/carga de nitro e estado do veículo. Lê schemas 1–4 sem apagar personalizações. Settings em arquivo separado `user://settings.cfg`; save/fotos permanecem no mesmo diretório do jogador.

## Próximas etapas propostas

1. **Corrida contra o relógio:** largada com contagem, checkpoints em ordem, chegada, tempo final, recorde e reiniciar. Validar a corrida completa antes de colocar dinheiro.
2. **Primeiro circuito urbano:** um bairro pequeno com ruas, cruzamentos, barreiras e oficina como ponto de retorno. Começar com área compacta para medir desempenho antes de ampliar a cidade.
3. **Adversários:** trajetórias, controle de velocidade, recuperação de bloqueios e classificação. Separar IA de direção e regras da corrida.
4. **Economia local:** saldo, prêmios por posição/tempo, catálogo com preços e peças possuídas; compra e instalação separadas, inventário e save versionado. Conceder prêmio uma única vez por corrida concluída, impedindo repetir a tela para duplicar dinheiro. Dar uma montagem inicial utilizável e uma forma de recuperar carro quebrado sem bloquear o jogador.
5. **Progressão:** novas provas e regiões, peças mais caras, reparos e recarga pagos com custo visível, equilíbrio entre prêmio e manutenção. Manter provas de teste gratuitas antes da compra.

Ciclo pretendido: correr → ganhar dinheiro → voltar à oficina → comprar/instalar peças ou reparar → disputar provas maiores. Essas etapas são planejamento; cidade, adversários, carteira e compras não estão implementados nesta entrega. Não foi escolhida uma moeda nem uma tabela de preços.

## Teste no Windows

Abra o ZIP exportado e escolha Garagem. Confira os móveis ao girar a câmera. Em Desempenho compare Original e Competição; instale nitro, vá à pista, acelere e pressione SHIFT. Confira redução da carga. Bata de frente numa barreira, observe estado e redução de desempenho; pare e repare. Volte à garagem e confira restauração visual, salve e reabra. Teste configurações e confirme a tela em até 15 segundos. O ambiente de desenvolvimento Linux não substitui esse teste.
