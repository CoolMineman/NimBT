import json

let buffersize = 100

var f: File

var inputbuffer: array[100, uint8]
var bytesread: int
var indexlocation = 0

type
    NBTKind = enum  # the different node types
        tagString,
        tagCompound
    NBTNode = ref NBTNodeObj
    NBTNodeObj = object
        name: string
        case kind: NBTKind  # the ``kind`` field is the discriminator
        of tagString:
            value: string
        of tagCompound:
            entries: seq[NBTNode]

proc readByte(): uint8 =
    if (indexlocation >= buffersize):
        indexlocation = 0
        bytesread = readBytes(f, inputbuffer, 0, buffersize) # todo hardcoding 0 may be broken
    result = inputbuffer[indexlocation]
    indexlocation += 1
    #echo indexlocation

proc readString(): string = 
    var length: uint16 = readByte()
    length = length shl 8
    length += readByte()
    for i in 1..int32(length):
        result = result & char(readByte())

proc readTagString: NBTNode =
    result = NBTNode(kind: tagString)
    result.name = readString()
    result.value = readString()

proc readTagCompound(): NBTNode =
    result = NBTNode(kind: tagCompound)
    result.name = readString()
    result.entries = newSeq[NBTNode](0)
    while true:
        case readByte()
        of 8:
            var a: NBTNode = readTagString()
            result.entries.add(a)
        of 0:
            break
        else:
            echo "bad nbt type"

if open(f, "test.nbt"):
    bytesread = readBytes(f, inputbuffer, 0, buffersize)
    if (bytesread > 0 and readByte() == 10):
        let a = readTagCompound()
        echo %*a
    else:
        echo "bad nbt file"