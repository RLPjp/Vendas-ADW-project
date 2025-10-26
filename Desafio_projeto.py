# Lista para armazenar os itens
itens = []

# Solicita os 3 itens ao usuário
for i in range(3):
    item = input()
    itens.append(item)
print(itens)
# Exibe a lista de itens
print("Lista de itens:")
for item in itens:
    print(f"- {item}")
