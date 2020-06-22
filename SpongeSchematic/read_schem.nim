import sponge_schematic, ../NBTParser/nbt, ../NBTParser/parsenbt
import json

proc readVarIntArray(inBytes: seq[int8]): seq[int32] =
    var i = 0
    var value: int32 = 0
    var varint_length = 0
    while i < inBytes.len:
        value = 0
        varint_length = 0

        while true:
            value = value or ( (inBytes[i] and 127) shl (varint_length * 7) )
            varint_length += 1
            if varint_length > 5:
                echo "VarInt too big (probably corrupted data)"
            if (inBytes[i] and 128) != 128:
                i += 1
                break
            i += 1
        result.add(value)


var a = readNBTFile("ktree10.schem")
var newSchem: Schematic = Schematic()
var blockdata: seq[int32]

for b in a.entries:
    case b.name:
    of "Version":
        newSchem.version = b.int32value
    of "Data Version":
        newSchem.data_version = b.int32value
    of "Metadata":
        var c = Metadata()
        for d in b.entries:
            case d.name:
            of "Name":
                c.name = d.stringvalue
            of "Author":
                c.author = d.stringvalue
            of "Date":
                c.date = d.int64value
            of "RequiredMods":
                c.required_mods = newSeq[string](0)
                for e in d.entries:
                    c.required_mods.add(e.stringvalue)
    of "Width":
        newSchem.width = cast[uint16](b.int16value)
    of "Height":
        newSchem.height = cast[uint16](b.int16value)
    of "Length":
        newSchem.length = cast[uint16](b.int16value)
    of "Offset":
        newSchem.offset = [b.intArrayValue[0], b.intArrayValue[1], b.intArrayValue[2]]
    of "Palette":
        var c = newSeq[string](0)
        for d in b.entries:
            while d.int32value > c.len - 1:
                c.add("")
            c[d.int32value] = d.name
        newSchem.palette = c
    of "BlockData":
        blockdata = readVarIntArray(b.byteArrayValue)
    of "BlockEntities":
        newSchem.block_entities = b.entries
    of "Entities":
        newSchem.entities = b.entries
    # todo more fancy stuff

echo newSchem.block_data

newSchem.block_data = newSeq[seq[seq[int32]]](0)

for i in 0..(uint32(newSchem.width)-1):
    newSchem.block_data.add(newSeq[seq[int32]](0))
    for j in 0..(uint32(newSchem.height)-1):
        newSchem.block_data[i].add(newSeq[int32](0))
        for k in 0..(uint32(newSchem.length)-1):
            let index: uint32 = i + (k * newSchem.width) + (j * newSchem.width * newSchem.length)
            newSchem.block_data[i][j].add(blockdata[index])

echo %*newSchem