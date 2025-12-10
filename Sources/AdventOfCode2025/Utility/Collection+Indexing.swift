import Foundation

extension Collection {
    subscript(safe index: Index) -> Element? {
        _read {
            if indices.contains(index) {
                yield self[index]
            } else {
                yield nil
            }
        }
    }
    
    subscript(index: SIMD2<Index>) -> Element.Element
    where Index: SIMDScalar, Element: Collection, Element.Index == Index {
        _read {
            yield self[index.x][index.y]
        }
    }
}

extension MutableCollection {
    subscript(safe index: Index) -> Element? {
        _read {
            if indices.contains(index) {
                yield self[index]
            } else {
                yield nil
            }
        }
        _modify {
            if indices.contains(index) {
                var temp: Element? = self[index]
                yield &temp
                if let newValue = temp {
                    self[index] = newValue
                }
            } else {
                var temp: Element? = nil
                yield &temp
            }
        }
    }
    
    subscript(index: SIMD2<Index>) -> Element.Element
    where Index: SIMDScalar, Element: MutableCollection, Element.Index == Index {
        _read {
            yield self[index.x][index.y]
        }
        _modify {
            yield &self[index.x][index.y]
        }
    }
}
