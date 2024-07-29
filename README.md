# Phonevox FIX: paloSantoMonitoring.class.php Issabel4 (px-fix-monitoring-class)

**pt-BR**: Script para a correção da "monitoring.class.php" do Issabel4.<br>
**en-US**: Script to fix "monitoring.class.php" in Issabel4.

# Descrição

Este fix foi criado com a intenção de fazer as gravações estarem SEMPRE relacionadas ao caminho que está inserido em `astspooldir` (`/etc/asterisk/asterisk.conf`), ao tentar baixá-las pela interface web do Issabel4.
Exemplificando: Assuma que *astspooldir* refere-se à `/var/spool/asterisk/monitor`.<br>
Ao salvar a ligação "#1", a mesma será salva em `<astspooldir>/monitor/<ano>/<mes>/<dia>/<callfile>` (*/var/spool/asterisk/monitor/2024/07/29/<callfile>*)<br>

Se posteriormente *astspooldir* for alterado, por exemplo, para `/mnt/recordings/`, as novas gravações serão salvas com base neste local (*/mnt/recordings/monitor/2024/07/29/<callfile>*), e as gravações anteriores (neste caso, a gravação #1) será dada como "Gravação perdida" no Issabel.

Para solucionar este problema, precisamos __sempre__ mover as gravações para o novo *astspooldir*, na estrutura correta (recomenda-se mover a pasta *monitor* em si), e precisamos alterar a "monitoring.class.php" para que SEMPRE ASSUMA que as gravações estejam vindo de *astspooldir*.

Isso é necessário pois as gravações *as vezes* são salvas com diretórios relativos (com base à *astspooldir*), e em outras vezes, são salvas com diretórios absolutos (*caminho completo desde root*) no banco de dados. Basicamente, alteramos essa classe para sempre assumir que o diretório é relativo à *astspooldir*.

**NOTA**: *Quero deixar bem claro que não me aprofundei o suficiente no código do Asterisk/Issabel4 para entender o porquê as gravações são salvas hora "absolutamente", hora "relativamente". Esta foi a maneira rápida/eficiente que nosso time encontrou para solucionar este problema.*

# Instalação

```sh
git clone https://github.com/adriankubinyete/px-fix-monitoring-class.git
cd px-fix-monitoring-class
chmod +x install.sh
./install.sh
```
**NOTA**: *O instalador precisa ser executado como root.*<br>
**NOTA**: *Pretendo simplificar o método de instalação.*

# Uso

Rode o instalador e, caso necessário, interaja com o terminal.

O instalador gera uma cópia do arquivo `paloSantoMonitoring.class.php`, e sobe o arquivo editado em seu lugar. Caso precise alterar para o antigo, é só substituir o arquivo atual pelo `paloSantoMonitoring.class.php.backup-<TIMESTAMP>`, na mesma pasta.
