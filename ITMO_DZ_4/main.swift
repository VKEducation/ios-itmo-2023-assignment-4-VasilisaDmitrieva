import Foundation

//var ff = Array<Int>()
var ff = ThreadSafeArray<Int>()

for index in 0..<100 {
    DispatchQueue.global().async {
        ff.append(index)
        print(ff.count)
    }
}
sleep(100)

let sd = ff[0]
