import ../NBTParser/nbt

type
    Metadata* = object
        name*: string
        author*: string
        date*: int64
        required_mods*: seq[string]
    Schematic* = object
        version*: int32
        data_version*: int32
        metadata*: Metadata
        width*: uint16
        height*: uint16
        length*: uint16
        offset*: array[3, int32]
        palette*: seq[string]
        #* Formated in x, y, z
        block_data*: seq[seq[seq[int32]]]
        block_entities*: seq[NBTNode]
        entities*: seq[NBTNode]
        biome_palette*: seq[string]
        biome_data*: seq[seq[int32]]