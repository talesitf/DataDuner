# Insper: Programação Funcional

Repositório com devcontainer para a utilização na disciplina Programação Funcional no Insper.

Passos para montar o ambiente:

1. Instalar o VS Code
1. Instalar o WSL no Windows
1. Instalar a extensão Dev Containers no VS Code
1. Clonar o repositório no WSL
1. Abrir o diretório no VS Code e seguir os passos

Obs: talvez precise realizar a instalação do docker no WSL. Seguir instalação padrão.

---

Outras observações:

- Caso queira montar o container localmente, basta montar o dockerfile
- Caso queira realizar a instalação manualmente, seguir os passos contidos no arquivo Dockerfile (atenção para o usuário)
- Não esquecer de rodar o postCreate.sh
- Acessar o OCaml REPL: $ ocaml 
  - para sair ctrl+d
- Acessar o Haskell REPL: $ ghci 
  - para sair :q
- Instalar as extensões de preferência para a sintaxe para o VS Code
- Sugestão: colocar os arquivos de exercícios no diretório ./src
- Sugestão II: Prefira o uso do WSL ao Windows diretamente