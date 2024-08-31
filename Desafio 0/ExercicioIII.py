def retornasubconjuntos(valores):

    if len(valores) == 0:
        return [[]]
    
    subconjuntovazio = retornasubconjuntos(valores[:-1])
    

    subconjuntocom = [subconjunto + [valores[-1]] for subconjunto in subconjuntovazio]
    
    return subconjuntovazio + subconjuntocom

valores = [1, 2,3,4,5]
resultado = retornasubconjuntos(valores)
print(resultado)
