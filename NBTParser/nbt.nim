type
    NBTKind* = enum  # the different node types
        tagString,
        tagCompound,
        tagList,
        tagByte,
        tagShort,
        tagInt,
        tagLong,
        tagFloat,
        tagDouble,
        tagByteArray,
        tagIntArray,
        tagLongArray
    NBTNode* = ref NBTNodeObj
    NBTNodeObj* = object
        name*: string
        case kind*: NBTKind  # the ``kind`` field is the discriminator
        of tagString:
            stringvalue*: string
        of tagCompound, tagList:
            entries*: seq[NBTNode]
        of tagByte:
            int8value*: int8
        of tagShort:
            int16value*: int16
        of tagInt:
            int32value*: int32
        of tagLong:
            int64value*: int64
        of tagFloat:
            float32value*: float32
        of tagDouble:
            float64value*: float64
        of tagByteArray:
            byteArrayValue*: seq[int8]
        of tagIntArray:
            intArrayValue*: seq[int32]
        of tagLongArray:
            longArrayValue*: seq[int64]