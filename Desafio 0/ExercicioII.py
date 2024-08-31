import array as arr

def calculoparaadif(numeros):
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

    print(listanumerodif)



numeros = arr.array('i', [41,56,32,11,45,78,99,3])

calculoparaadif(numeros)
