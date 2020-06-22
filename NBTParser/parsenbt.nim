import json

let buffersize = 100

var f: File

var inputbuffer: array[100, uint8]
var bytesread: int
var indexlocation = 0

type
    NBTKind = enum  # the different node types
        tagString,
        tagCompound,
        tagList,
        tagByte,
        tagShort,
        tagInt,
        tagLong
    NBTNode = ref NBTNodeObj
    NBTNodeObj = object
        name: string
        case kind: NBTKind  # the ``kind`` field is the discriminator
        of tagString:
            stringvalue: string
        of tagCompound, tagList:
            entries: seq[NBTNode]
        of tagByte:
            int8value: int8
        of tagShort:
            int16value: int16
        of tagInt:
            int32value: int32
        of tagLong:
            int64value: int64

proc readByte(): uint8 =
    if (indexlocation >= buffersize):
        indexlocation = 0
        bytesread = readBytes(f, inputbuffer, 0, buffersize) # todo hardcoding 0 ~~may be~~ is broken
    result = inputbuffer[indexlocation]
    indexlocation += 1
    #echo indexlocation

proc readString(): string = 
    var length: uint16 = readByte()
    length = length shl 8
    length += readByte()
    for i in 1..int32(length):
        result = result & char(readByte())

proc readInt8(): int8 =
    return cast[int8](readByte())

proc readInt16(): int16 =
    var a: uint16 = 0
    a += readByte()
    a = a shl 8
    a += readByte()
    return cast[int16](a)

proc readInt32(): int32 =
    var a: uint32 = 0
    a += readByte()
    a = a shl 8
    a += readByte()
    a = a shl 8
    a += readByte()
    a = a shl 8
    a += readByte()
    return cast[int32](a)

proc readInt64(): int64 =
    var a: uint64 = 0
    a += readByte()
    a = a shl 8
    a += readByte()
    a = a shl 8
    a += readByte()
    a = a shl 8
    a += readByte()
    a = a shl 8
    a += readByte()
    a = a shl 8
    a += readByte()
    a = a shl 8
    a += readByte()
    a = a shl 8
    a += readByte()
    return cast[int64](a)

proc readNode(tagID: uint8): NBTNode =
    case tagID
    of 8:
        result = NBTNode(kind: tagString)
        result.stringvalue = readString()
    of 1:
        result = NBTNode(kind: tagByte)
        result.int8value = readInt8()
    of 2:
        result = NBTNode(kind: tagShort)
        result.int16value = readInt16()
    of 3:
        result = NBTNode(kind: tagInt)
        result.int32value = readInt32()
    of 4:
        result = NBTNode(kind: tagLong)
        result.int64value = readInt64()
    else:
        echo "no"
    

proc readTagCompoundOrList(named: bool, isList: bool): NBTNode =
    if isList:
        result = NBTNode(kind: tagList)
    else:
        result = NBTNode(kind: tagCompound)
    if named:
        result.name = readString()
    result.entries = newSeq[NBTNode](0)
    if isList:
        let tagID = readByte()
        let length = readInt32()
        if length > 0:
            for _ in 1..length:
                case tagID
                of 1, 2, 3, 4, 8:
                    result.entries.add(readNode(tagID))
                of 9:
                    result.entries.add(readTagCompoundOrList(false, true))
                of 10:
                    result.entries.add(readTagCompoundOrList(false, false))
                else:
                    echo "no"
    else:
        while true:
            var a = readByte()
            case a
            of 1, 2, 3, 4, 8:
                var name = readString()
                var b = readNode(a)
                b.name = name
                result.entries.add(b)
            of 9:
                result.entries.add(readTagCompoundOrList(true, true))
            of 10:
                result.entries.add(readTagCompoundOrList(true, false))
            of 0:
                break
            else:
                echo "bad nbt type"
                break
    

if open(f, "test3.nbt"):
    bytesread = readBytes(f, inputbuffer, 0, buffersize)
    if (bytesread > 0 and readByte() == 10):
        let a = readTagCompoundOrList(named = true, isList = false)
        echo %*a
    else:
        echo "bad nbt file"