import Foundation
class System {
    let success = "✅ Successfully! ✅"
    let error = "🟥 Error! 🟥"
    let separator = "▼——————————————————————▼"
    
    func replaceFirstLetter(array: [String], replaceable: Character, replaceOn: Character) -> [String] {
        var arrayCopy = array
        for v in 0..<arrayCopy.count {
            if String(arrayCopy[v][arrayCopy[v].startIndex]) == String(replaceable) {
                arrayCopy[v].remove(at: arrayCopy[v].startIndex)
                arrayCopy[v] = [replaceOn] + arrayCopy[v]
            }
        }
        return arrayCopy
    }
    func getDataFromUser(message: String) -> String {
        print(message)
        return readLine() ?? getDataFromUser(message: error + "\n" + message)
    }
    func getIntFromUser(message: String) -> Int {
        return Int(getDataFromUser(message: message)) ?? getIntFromUser(message: error + "\n" + message)
    }
    
    
    let lengthDefend = {(input: String, length: Int) -> Bool in
        input.count == length ? false: true
    }
    let minIntDefend = {(input: Int, minValue: Int) -> Bool in
        input >= minValue ? false: true}
    let containDefend = {(input: String, collection: [String]) -> Bool in
        collection.contains(input) ? true: false}
    let stopDefend = {(input: String, collection: [String], minCountValue: Int) -> Bool in
        input == "" && collection.count >= minCountValue ? true : false}
    func defend(stop: Bool, defences: [Bool]) -> (Bool,Bool) {
        stop == true ? (true, false): defences.contains(true) ? (false, true): (false, false)
    }
    
}
class Vertices: System {
    //DATA
    var values: [String]
    //CREATE DATA
    func createValues() {
        let input = getIntFromUser(message: "▶ Введите количество вершин: ")
        let defend = defend(stop: false, defences: [minIntDefend(input,2)])
        if defend.1 == true {
            print(error)
            self.createValues()
        }else {
            for i in 0..<input {
                self.values.append("q\(i)")
            }
        }
    }
    //INIT'S
    init(values: [String]) {
        self.values = values
    }
    override init() {
        self.values = []
    }
}
class Alphabet: System {
    //DATA
    var values: [String]
    //CREATE DATA
    func createValues() {
        self.values = []
        while true {
            let input = getDataFromUser(message: "▶ Введите букву в алфавит: ")
            let defend = defend(stop: stopDefend(input,values,2), defences: [lengthDefend(input,1)])
            if defend.0 == true {
                print(success)
                return
            }
            if defend.1 == false {
                self.values.append(input)
            }else {
                print(error)
                continue
                
            }
        }
    }
    //INIT'S
    init(values: [String]) {
        self.values = values
    }
    override init() {
        self.values = []
    }
}
class StartVertices: System {
    //DATA
    let valueQ: String = "q0"
    var valuesS: [String]
    var valuesP: [String]
    //CREATE DATA
    func createValuesS(epsilonClosure: EpsilonClosure) {
        if let epsilonValue = epsilonClosure.dictionary[valueQ] {
            valuesS = replaceFirstLetter(array: epsilonValue, replaceable: "q", replaceOn: "S")
        }
    }
    //INIT'S
    override init() {
        self.valuesS = []
        self.valuesP = []
    }
}
class Transitions: System {
    //DATA
    var dictionary: [String: [String]]
    //CREATE DATA
    func createDictionary(vertices: Vertices, alphabet: Alphabet) {
        for i in vertices.values {
        second: for j in alphabet.values + ["E"]{
                var bin: [String] = []
                while true {
                    let input = getDataFromUser(message: "▶ Введите переход из \(i) по \(j): ")
                    let defend = defend(stop: stopDefend(input,bin, 1), defences: [!containDefend(input,vertices.values)])
                    if input == "0" {
                        self.dictionary["\(i)_\(j)"] = []
                        continue second
                    }
                    if defend.0 == true {
                        self.dictionary["\(i)_\(j)"] = bin
                        continue second
                    }
                    if defend.1 == false {
                        bin.append(input)
                    }else {
                        print(error)
                    }
                }
            }
        }
    }
    //INIT'S
    init(dictionary: [String : [String]]) {
        self.dictionary = dictionary
    }
    override init() {
        self.dictionary = [:]
    }
}
class EpsilonClosure: System {
    //DATA
    var dictionary: [String: [String]]
    //CREATE DATA
    func createDictionary(vertices: Vertices, alphabet: Alphabet, transitions: Transitions) {
        self.dictionary = [:]
        for (i,g) in zip(vertices.values,0..<vertices.values.count) {
            var bin: [String] = [i]
            var indexCheck = 0
            if let epsilonValue = transitions.dictionary["\(i)_E"] {
                bin += epsilonValue
            }
            while indexCheck < bin.count {
                for j in indexCheck..<bin.count {
                    if let epsilonValue = transitions.dictionary["\(bin[j])_E"] {
                        bin += epsilonValue
                    }
                    indexCheck += 1
                }
            }
            //clean bin on same value
            bin = bin.reduce([]) { result, element in
                result.contains(element) ? result : result + [element]
            }
            self.dictionary["q\(g)"] = bin
            bin = []
        }
    }
    //INIT'S
    override init() {
        self.dictionary = [:]
    }
}
class TableS: System {
    //DATA
    var dictionary: [String: [String]]
    //CREATE DATA
    func createDictionary(vertices: Vertices, alphabet: Alphabet, transitions: Transitions, epsilonClosures: EpsilonClosure) {
        //Берем епсилон замыкание arrayFromEpsilonChain
        for (i,p) in zip(vertices.values, 0..<vertices.values.count) {
            //Берем букву j
            for j in alphabet.values {
                //Создаем итоговое хранилище
                var out: [String] = []
                if let arrayFromEpsilonChain = epsilonClosures.dictionary["\(i)"] {
                    //Берем вершины g из епсилон замыкания
                    for g in arrayFromEpsilonChain {
                        //Берем переход по букве для этой вершины (4)
                        if let arrayFromTop = transitions.dictionary[g+"_"+j] {
                            //Добавляем все в итог, кроме 0
                            if !arrayFromTop.isEmpty {
                                //Первый сценарий (самый простой)
                                for h in arrayFromTop {
                                    out.append(h)
                                }
                                //Второй сценарий, когда потом идем еще по епсилон
                                for f in out {
                                    if let arrayFromEpsilonLast = epsilonClosures.dictionary["\(f)"] {
                                        if !arrayFromEpsilonLast.isEmpty {
                                            for k in arrayFromEpsilonLast {
                                                out.append(k)
                                            }
                                        }
                                    }
                                }
                                //Третий сценарий, когда сначала идем по епсилон а потом по букве
                                var outTemp3: [String] = []
                                if let arrayFromEpsilonFirst = epsilonClosures.dictionary["\(g)"] {
                                    if !arrayFromEpsilonFirst.isEmpty {
                                        for l in arrayFromEpsilonFirst {
                                            if l != g {
                                                outTemp3.append(l)
                                            }
                                        }
                                    }
                                }
                                //Идем по букве
                                if outTemp3.count > 0 {
                                    for n in outTemp3 {
                                        if let arrayFromTransitionLast = transitions.dictionary[n+"_"+j] {
                                            if !arrayFromTransitionLast.isEmpty {
                                                for m in arrayFromTransitionLast {
                                                    out.append(m)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                //clear out by same value
                out = out.reduce([]) { result, element in
                    result.contains(element) ? result : result + [element]
                }
                //replace "q" on "S" in values
                for v in 0..<out.count {
                    if out[v][out[v].startIndex] == "q" {
                        out[v].remove(at: out[v].startIndex)
                        out[v].insert("S", at: out[v].startIndex)
                    }
                }
                self.dictionary["S\(p)_\(j)"] = out
            }
        }
    }
    //INIT'S
    override init() {
        self.dictionary = [:]
    }
}
class TableP: System {
    //DATA
    var dictionary: [String: [String]]
    var dictionary2: [String: [String]]
    //CREATE DATA
    func createDictionary(tableS: TableS, alphabet: Alphabet, startVerticesS: StartVertices) {
        var indexCheck = 0
        var arrayPALL = ["P0"]
        var arrayP = ["P0"]
        var dictionaryP: [String: [String]] = [:]
        dictionaryP["P0"] = startVerticesS.valuesS
        
        while indexCheck < arrayPALL.count { //ALL
            for i in arrayP { //not ALL
                for j in alphabet.values {
                    //Берем массив вершин из P
                    if let value = dictionaryP[i] {
                        var bin: Set<String> = []
                        for k in value {
                            //Берем потенциальное значение
                            if let newValue = tableS.dictionary["\(k)_\(j)"] {
                                //Если пустое значение
                                if newValue.isEmpty {
                                    continue
                                }else {
                                    bin = bin.union(newValue)
                                }
                            }
                        }
                        let arrayFromSet = Array(bin).sorted(by: {$0 < $1})
                        if arrayFromSet.isEmpty {
                            self.dictionary["\(i)_\(j)"] = []
                            //dictionaryP["P\(dictionaryP.keys.count)"] = arrayFromSet
                        }else if dictionaryP.values.contains(arrayFromSet) {
                            for l in dictionaryP.keys.sorted(by: {$0 < $1}) {
                                if let checkValue = dictionaryP[l] {
                                    if arrayFromSet == checkValue {
                                        self.dictionary["\(i)_\(j)"] = [l]
                                    }
                                }
                            }
                        }else {
                            arrayP.append("P\(dictionaryP.keys.count)")
                            arrayPALL.append("P\(dictionaryP.keys.count)")
                            self.dictionary["\(i)_\(j)"] = ["P\(dictionaryP.keys.count)"]
                            dictionaryP["P\(dictionaryP.keys.count)"] = arrayFromSet
                        }
                    }
                }
                arrayP.removeFirst()
                indexCheck += 1
            }
        }
        self.dictionary2 = dictionaryP
        print(self.dictionary)
    }
    //INIT'S
    override init() {
        self.dictionary = [:]
        self.dictionary2 = [:]
    }
}
class EndVertices: System {
    //DATA
    var valuesQ: [String]
    var valuesS: [String]
    var valuesP: [String]
    //CREATE DATA
    func createValuesQ(vertices: Vertices, startVertices: StartVertices) {
        while true {
            let input = getDataFromUser(message: "▶ Введите конечную вершину из \(vertices.values):")
            let defend = defend(stop: stopDefend(input, self.valuesQ, 1), defences: [!containDefend(input, vertices.values), containDefend(input,self.valuesQ), input == startVertices.valueQ])
            if defend.0 == true {
                return
            }
            if defend.1 == false {
                self.valuesQ.append(input)
            }else {
                print(error)
            }
        }
    }
    func createValuesS(epsilonClosure: EpsilonClosure) {
        var bin: [String] = []
        for i in epsilonClosure.dictionary.keys.sorted(by: {$0 < $1}) {
            if let value = epsilonClosure.dictionary[i] {
                if Set(value) == Set(valuesS) || !Set(value).intersection(valuesQ).isEmpty {
                    bin.append(i)
                }
            }
        }
        self.valuesS = replaceFirstLetter(array: bin, replaceable: "q", replaceOn: "S")
    }
    func createValuesP(tableP: TableP) {
        for i in tableP.dictionary2.keys.sorted(by: {$0 < $1}) {
            if let value = tableP.dictionary2[i] {
                if Set(value) == Set(valuesS) || !Set(value).intersection(valuesS).isEmpty {
                    self.valuesP.append(i)
                }
            }
        }
    }
    //INIT'S
    init(valuesQ: [String]) {
        self.valuesQ = valuesQ
        self.valuesS = []
        self.valuesP = []
    }
    override init() {
        self.valuesQ = []
        self.valuesS = []
        self.valuesP = []
    }
}
class checkWord: System {
    //DATA
    var value: String
    //CREATE DATA
    func createValue(alphabet: Alphabet) {
    main: while true {
            let input = getDataFromUser(message: "▶ Введите слово для проверки: ")
        if input.isEmpty {
            print(error)
            continue
        }
            for i in input {
                if !alphabet.values.contains(String(i)) {
                    print(error)
                    continue main
                }
            }
            self.value = input
            break
        }
    }
    func checkWord(tableP: TableP, endVertices: EndVertices) {
        var vertex = "P0"
        var letter = value.first!
        var count = 0
        
        while count < value.count {
            if count == value.count - 1 {
                if let checkEndVertex = tableP.dictionary["\(vertex)_\(letter)"] {
                    if Set(endVertices.valuesP).isSuperset(of: checkEndVertex) {
                        print("Yes")
                    }else {
                        print("No")
                    }
                    return
                }
            }
            if let nextTransition = tableP.dictionary["\(vertex)_\(letter)"] {
                if nextTransition.isEmpty {
                    print("No")
                    return
                }else {
                    count += 1
                    vertex = nextTransition[0]
                    letter = value[value.index(value.startIndex, offsetBy: count)]
                }
            }
        }
    }
    //INIT'S
    init(value: String) {
        self.value = value
    }
    override init() {
        self.value = ""
    }
}

var verticesObject = Vertices.init()
verticesObject.createValues()
print(verticesObject.values)

var alphabetObject = Alphabet.init()
alphabetObject.createValues()
print(alphabetObject.values)

var startVerticesObject = StartVertices.init()

var transitionsObject = Transitions.init()
transitionsObject.createDictionary(vertices: verticesObject, alphabet: alphabetObject)

var epsilonClosureObject = EpsilonClosure.init()
epsilonClosureObject.createDictionary(vertices: verticesObject, alphabet: alphabetObject, transitions: transitionsObject)
print("Епсилон переходы:\(epsilonClosureObject.dictionary)")

startVerticesObject.createValuesS(epsilonClosure: epsilonClosureObject)

var TableSObject = TableS.init()
TableSObject.createDictionary(vertices: verticesObject, alphabet: alphabetObject, transitions: transitionsObject, epsilonClosures: epsilonClosureObject)
print("Таблица S:\(TableSObject.dictionary)")

var tablePObject = TableP.init()
print("Таблица P:")
tablePObject.createDictionary(tableS: TableSObject, alphabet: alphabetObject, startVerticesS: startVerticesObject)

var endVerticesObject = EndVertices.init()
endVerticesObject.createValuesQ(vertices: verticesObject, startVertices: startVerticesObject)
endVerticesObject.createValuesS(epsilonClosure: epsilonClosureObject)
endVerticesObject.createValuesP(tableP: tablePObject)

var checkWordObject = checkWord.init()
checkWordObject.createValue(alphabet: alphabetObject)
checkWordObject.checkWord(tableP: tablePObject, endVertices: endVerticesObject)

