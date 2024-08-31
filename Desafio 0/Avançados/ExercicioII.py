import array as arr

def calculoparaadif(numeros, allow_duplicates=False, sorted_pairs=False, unique_pairs=False):
    
    numeros = sorted(numeros)

    menordif = float('inf')
    listanumerodif = []

    for i in range(len(numeros) - 1):
        dif = numeros[i + 1] - numeros[i]

        if dif < menordif:
            menordif = dif
            listanumerodif = [(numeros[i], numeros[i + 1])]
        elif dif == menordif:
            listanumerodif.append((numeros[i], numeros[i + 1]))

    if not allow_duplicates:
        listanumerodif = [(a, b) for a, b in listanumerodif if a != b]

    if sorted_pairs:
        listanumerodif = [tuple(sorted(pair)) for pair in listanumerodif]

    if unique_pairs:
        listanumerodif = list(set(listanumerodif))

    if sorted_pairs:
        listanumerodif.sort()

    print(listanumerodif)


numeros = arr.array('i', [4, 2, 1, 5, 6,4,7,6,1,2])
calculoparaadif(numeros, allow_duplicates=True, sorted_pairs=True, unique_pairs=True)
