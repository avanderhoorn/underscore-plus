_ = require '../src/underscore-plus'

describe "underscore extensions", ->
  describe "::adviseBefore(object, methodName, advice)", ->
    [object, calls] = []

    beforeEach ->
      calls = []
      object = {
        method: (args...) ->
          calls.push(["original", this, args])
      }

    it "calls the given function before the advised method", ->
      _.adviseBefore object, 'method', (args...) -> calls.push(["advice", this, args])
      object.method(1, 2, 3)
      expect(calls).toEqual [['advice', object, [1, 2, 3]], ['original', object, [1, 2, 3]]]

    it "cancels the original method's invocation if the advice returns true", ->
      _.adviseBefore object, 'method', -> false
      object.method(1, 2, 3)
      expect(calls).toEqual []

  describe "::endsWith(string, ending)", ->
    it "returns whether the given string ends with the given suffix", ->
      expect(_.endsWith("test.txt", ".txt")).toBeTruthy()
      expect(_.endsWith("test.txt", "txt")).toBeTruthy()
      expect(_.endsWith("test.txt", "test.txt")).toBeTruthy()
      expect(_.endsWith("test.txt", "")).toBeTruthy()
      expect(_.endsWith("test.txt", ".txt2")).toBeFalsy()
      expect(_.endsWith("test.txt", ".tx")).toBeFalsy()
      expect(_.endsWith("test.txt", "test")).toBeFalsy()

  describe "::camelize(string)", ->
    it "converts `string` to camel case", ->
      expect(_.camelize("corey_dale_johnson")).toBe "coreyDaleJohnson"
      expect(_.camelize("corey-dale-johnson")).toBe "coreyDaleJohnson"
      expect(_.camelize("corey_dale-johnson")).toBe "coreyDaleJohnson"
      expect(_.camelize("coreyDaleJohnson")).toBe "coreyDaleJohnson"
      expect(_.camelize("CoreyDaleJohnson")).toBe "CoreyDaleJohnson"

  describe "::dasherize(string)", ->
    it "converts `string` to use dashes", ->
      expect(_.dasherize("corey_dale_johnson")).toBe "corey-dale-johnson"
      expect(_.dasherize("coreyDaleJohnson")).toBe "corey-dale-johnson"
      expect(_.dasherize("CoreyDaleJohnson")).toBe "corey-dale-johnson"
      expect(_.dasherize("corey-dale-johnson")).toBe "corey-dale-johnson"

  describe "::underscore(string)", ->
    it "converts `string` to use underscores", ->
      expect(_.underscore('')).toBe ''
      expect(_.underscore(null)).toBe ''
      expect(_.underscore()).toBe ''
      expect(_.underscore('a_b')).toBe 'a_b'
      expect(_.underscore('A_b')).toBe 'a_b'
      expect(_.underscore('a-b')).toBe 'a_b'
      expect(_.underscore('TheOffice')).toBe 'the_office'
      expect(_.underscore('theOffice')).toBe 'the_office'
      expect(_.underscore('test')).toBe 'test'
      expect(_.underscore(' test ')).toBe ' test '
      expect(_.underscore('--ParksAndRec')).toBe '__parks_and_rec'
      expect(_.underscore("corey-dale-johnson")).toBe "corey_dale_johnson"
      expect(_.underscore("coreyDaleJohnson")).toBe "corey_dale_johnson"
      expect(_.underscore("CoreyDaleJohnson")).toBe "corey_dale_johnson"
      expect(_.underscore("corey_dale_johnson")).toBe "corey_dale_johnson"

  describe "::spliceWithArray(originalArray, start, length, insertedArray, chunkSize)", ->
    describe "when the inserted array is smaller than the chunk size", ->
      it "splices the array in place", ->
        array = ['a', 'b', 'c']
        _.spliceWithArray(array, 1, 1, ['v', 'w', 'x', 'y', 'z'], 100)
        expect(array).toEqual ['a', 'v', 'w', 'x', 'y', 'z', 'c']

    describe "when the inserted array is larger than the chunk size", ->
      it "splices the array in place one chunk at a time (to avoid stack overflows)", ->
        array = ['a', 'b', 'c']
        _.spliceWithArray(array, 1, 1, ['v', 'w', 'x', 'y', 'z'], 2)
        expect(array).toEqual ['a', 'v', 'w', 'x', 'y', 'z', 'c']

  describe "::humanizeEventName(eventName)", ->
    describe "when no namespace exists", ->
      it "undasherizes and capitalizes the event name", ->
        expect(_.humanizeEventName('nonamespace')).toBe 'Nonamespace'
        expect(_.humanizeEventName('no-name-space')).toBe 'No Name Space'

    describe "when a namespaces exists", ->
      it "space separates the undasherized/capitalized versions of the namespace and event name", ->
        expect(_.humanizeEventName('space:final-frontier')).toBe 'Space: Final Frontier'
        expect(_.humanizeEventName('star-trek:the-next-generation')).toBe 'Star Trek: The Next Generation'

  describe "::humanizeKeystroke(keystroke)", ->
    it "replaces single keystroke", ->
      expect(_.humanizeKeystroke('cmd-O')).toEqual '⌘⇧O'
      expect(_.humanizeKeystroke('cmd-shift-up')).toEqual '⌘⇧↑'
      expect(_.humanizeKeystroke('cmd-option-down')).toEqual '⌘⌥↓'
      expect(_.humanizeKeystroke('cmd-option-left')).toEqual '⌘⌥←'
      expect(_.humanizeKeystroke('cmd-option-right')).toEqual '⌘⌥→'
      expect(_.humanizeKeystroke('cmd-o')).toEqual '⌘O'
      expect(_.humanizeKeystroke('ctrl-2')).toEqual '⌃2'
      expect(_.humanizeKeystroke('cmd-space')).toEqual '⌘space'

      expect(_.humanizeKeystroke('cmd-|')).toEqual '⌘⇧\\'
      expect(_.humanizeKeystroke('cmd-}')).toEqual '⌘⇧]'
      expect(_.humanizeKeystroke('cmd--')).toEqual '⌘-'

    it "correctly replaces keystrokes with shift and capital letter", ->
      expect(_.humanizeKeystroke('cmd-shift-P')).toEqual '⌘⇧P'

    it "replaces multiple keystrokes", ->
      expect(_.humanizeKeystroke('cmd-O cmd-n')).toEqual '⌘⇧O ⌘N'
      expect(_.humanizeKeystroke('cmd-shift-- cmd-n')).toEqual '⌘⇧- ⌘N'

    it "formats function keys", ->
      expect(_.humanizeKeystroke('cmd-f2')).toEqual '⌘F2'

    it "handles junk input", ->
      expect(_.humanizeKeystroke()).toEqual undefined
      expect(_.humanizeKeystroke(null)).toEqual null
      expect(_.humanizeKeystroke('')).toEqual ''

  describe "::deepExtend(objects...)", ->
    it "copies all key/values from each object into a new object", ->
      first =
        things:
          string: "oh"
          boolean: false
          anotherArray: ['a', 'b', 'c']
          object:
            first: 1
            second: 2

      second =
        things:
          string: "cool"
          array: [1,2,3]
          anotherArray: ['aa', 'bb', 'cc']
          object:
            first: 1

      result = _.deepExtend(first, second)

      expect(result).toEqual
        things:
          string: "oh"
          boolean: false
          array: [1,2,3]
          anotherArray: ['a', 'b', 'c']
          object:
            first: 1
            second: 2

  describe "::isSubset(potentialSubset, potentialSuperset)", ->
    it "returns whether the first argument is a subset of the second", ->
      expect(_.isSubset([1, 2], [1, 2])).toBeTruthy()
      expect(_.isSubset([1, 2], [1, 2, 3])).toBeTruthy()
      expect(_.isSubset([], [1])).toBeTruthy()
      expect(_.isSubset([], [])).toBeTruthy()
      expect(_.isSubset([1, 2], [2, 3])).toBeFalsy()

  describe '::isEqual(a, b)', ->
    it 'returns true when the elements are equal, false otherwise', ->
      expect(_.isEqual(null, null)).toBe true
      expect(_.isEqual('test', 'test')).toBe true
      expect(_.isEqual(3, 3)).toBe true
      expect(_.isEqual({a: 'b'}, {a: 'b'})).toBe true
      expect(_.isEqual([1, 'a'], [1, 'a'])).toBe true

      expect(_.isEqual(null, 'test')).toBe false
      expect(_.isEqual(3, 4)).toBe false
      expect(_.isEqual({a: 'b'}, {a: 'c'})).toBe false
      expect(_.isEqual({a: 'b'}, {a: 'b', c: 'd'})).toBe false
      expect(_.isEqual([1, 'a'], [2])).toBe false
      expect(_.isEqual([1, 'a'], [1, 'b'])).toBe false

      a = isEqual: (other) -> other is b
      b = isEqual: (other) -> other is 'test'
      expect(_.isEqual(a, null)).toBe false
      expect(_.isEqual(a, 'test')).toBe false
      expect(_.isEqual(a, b)).toBe true
      expect(_.isEqual(null, b)).toBe false
      expect(_.isEqual('test', b)).toBe true

      expect(_.isEqual(/a/, /a/g)).toBe false
      expect(_.isEqual(/a/, /b/)).toBe false
      expect(_.isEqual(/a/gi, /a/gi)).toBe true

    it "calls custom equality methods with stacks so they can participate in cycle-detection", ->
      class X
        isEqual: (b, aStack, bStack) ->
          _.isEqual(@y, b.y, aStack, bStack)

      class Y
        isEqual: (b, aStack, bStack) ->
          _.isEqual(@x, b.x, aStack, bStack)

      x1 = new X
      y1 = new Y
      x1.y = y1
      y1.x = x1

      x2 = new X
      y2 = new Y
      x2.y = y2
      y2.x = x2

      expect(_.isEqual(x1, x2)).toBe true

    it "only accepts arrays as stack arguments to avoid accidentally calling with other objects", ->
      expect(-> _.isEqual({}, {}, "junk")).not.toThrow()
      expect(-> _.isEqual({}, {}, [], "junk")).not.toThrow()

  describe "::isEqualForProperties(a, b, properties...)", ->
    it "compares two objects for equality using just the specified properties", ->
      expect(_.isEqualForProperties({a: 1, b: 2, c: 3}, {a: 1, b: 2, c: 4}, 'a', 'b')).toBe true
      expect(_.isEqualForProperties({a: 1, b: 2, c: 3}, {a: 1, b: 2, c: 4}, 'a', 'c')).toBe false

  describe "::capitalize(word)", ->
    it "capitalizes the word", ->
      expect(_.capitalize('')).toBe ''
      expect(_.capitalize(null)).toBe ''
      expect(_.capitalize()).toBe ''
      expect(_.capitalize('Github')).toBe 'GitHub'
      expect(_.capitalize('test')).toBe 'Test'

  describe "::dasherize(word)", ->
    it "dasherizes the word", ->
      expect(_.dasherize('')).toBe ''
      expect(_.dasherize(null)).toBe ''
      expect(_.dasherize()).toBe ''
      expect(_.dasherize('a_b')).toBe 'a-b'
      expect(_.dasherize('test')).toBe 'test'

  describe "::uncamelcase(string)", ->
    it "uncamelcases the string", ->
      expect(_.uncamelcase('')).toBe ''
      expect(_.uncamelcase(null)).toBe ''
      expect(_.uncamelcase()).toBe ''
      expect(_.uncamelcase('a_b')).toBe 'A b'
      expect(_.uncamelcase('TheOffice')).toBe 'The Office'
      expect(_.uncamelcase('theOffice')).toBe 'The Office'
      expect(_.uncamelcase('test')).toBe 'Test'
      expect(_.uncamelcase(' test ')).toBe 'Test'
      expect(_.uncamelcase('__ParksAndRec')).toBe 'Parks And Rec'

  describe "::valueForKeyPath(object, keyPath)", ->
    it "retrieves the value at the given key path or undefined if none exists", ->
      object = {a: b: c: 2}
      expect(_.valueForKeyPath(object, 'a.b.c')).toBe 2
      expect(_.valueForKeyPath(object, 'a.b')).toEqual {c: 2}
      expect(_.valueForKeyPath(object, 'a.x')).toBeUndefined()

  describe "::setValueForKeyPath(object, keyPath, value)", ->
    it "assigns a value at the given key path, creating intermediate objects if needed", ->
      object = {}
      _.setValueForKeyPath(object, 'a.b.c', 1)
      _.setValueForKeyPath(object, 'd', 2)
      expect(object).toEqual {a: {b: c: 1}, d: 2}

  describe "::hasKeyPath(object, keyPath)", ->
    it "determines whether the given object has properties along the given key path", ->
      object = {a: b: c: 2}
      expect(_.hasKeyPath(object, 'a')).toBe true
      expect(_.hasKeyPath(object, 'a.b.c')).toBe true
      expect(_.hasKeyPath(object, 'a.b.c.d')).toBe false
      expect(_.hasKeyPath(object, 'a.x')).toBe false
