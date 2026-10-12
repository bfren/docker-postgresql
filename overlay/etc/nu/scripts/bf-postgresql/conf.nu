use bf
use bf-s6

# Generate data configuration files
export def generate [] {
    bf-s6 esh template (bf env PG_DATA_CONF)
    bf-s6 esh template (bf env PG_DATA_HBA_CONF)
}
