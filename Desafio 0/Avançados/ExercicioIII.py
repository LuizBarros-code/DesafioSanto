from itertools import combinations

def retornasubconjuntos(valores,max_size=None, min_size=0, distinct_only=False, sort_subsets=False):


    if distinct_only:
        valores = list(set(valores))
    
    subconjuntos = []

    for tamanho in range(min_size, len(valores) + 1):
        if max_size and tamanho > max_size:
            continue
        subconjuntos.extend(combinations(valores,tamanho))

    if sort_subsets:
        subconjuntos = [tuple(sorted(conjunto)) for conjunto in subconjuntos]
        subconjuntos = sorted(set(subconjuntos))
    

    subconjuntos = [list(conjunto) for conjunto in subconjuntos]
    
    return subconjuntos

valores = [1, 2,3,4,5,2]
resultado = retornasubconjuntos(valores,max_size=5, min_size=0, distinct_only=True, sort_subsets=True)
print(resultado)
