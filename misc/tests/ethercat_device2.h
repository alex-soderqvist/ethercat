enum { PERIOD_NS = 1000000 };
#define TIMESPEC2NS(T) ((uint64_t) (T).tv_sec * NSEC_PER_SEC + (T).tv_nsec)

typedef struct ec_addr ec_addr;
struct ec_addr
{
    int tag;
    int vaddr;
    char name[16];
    int period;
    uint64_t value;
    int client;
    int reason;
    int tick;
    int size;
    int datatype;
};

// put the datatype in the message

typedef struct ec_addr_buf ec_addr_buf;
struct ec_addr_buf
{
    ec_addr base;
    char buf[1024];
};

typedef struct pdo_entry_type pdo_entry_type;
struct pdo_entry_type
{
    char * name;
    // oversampling
    int length;
    // field mapping
    int buffer_offset;
    int buffer_size;
    // pdo mapping
    unsigned int * pdo_offset;
    unsigned int * pdo_bit;
    ec_sync_info_t * sync;
    ec_pdo_info_t * pdo;
    ec_pdo_entry_info_t * entry; 
    pdo_entry_type * next;
};

typedef struct field_t field_t;
struct field_t
{
    char * name;
    void * buffer;
    int size;
};

typedef struct ethercat_device ethercat_device;

struct ethercat_device
{
    char * name;
    ec_master_t * master;
    void (*process)(ethercat_device * self, uint8_t * pd);
    field_t * fields;
    int n_fields;
    int pos;
    char * usr;
    int oversample;
    int dcactivate;
    ec_sync_info_t syncs[EC_MAX_SYNC_MANAGERS];
    ec_slave_info_t slave_info;
    char * pdo_buffer;
    pdo_entry_type * regs;
    ethercat_device * next;
};

typedef struct ethercat_device_config ethercat_device_config;
struct ethercat_device_config
{
    char * name;
    int vaddr;
    int alias;
    int pos;
    char * usr;
    ethercat_device * dev;
    ethercat_device_config * next;
};

enum { S8 = 0, U8, S16, U16, S32, U32 };

struct master_device;
typedef struct master_device master_device;

field_t * find_field(ethercat_device_config * chain, ec_addr * loc);
int ethercat_device_read_field(field_t * f, void * buf, int max_buf);
int ethercat_device_write_field(field_t * f, void * buf, int max_buf);

void read_pdo(pdo_entry_type * r, uint8_t * pd, char * buffer);
void write_pdo(pdo_entry_type * r, uint8_t * pd, char * buffer);

ethercat_device * init_master_device(ec_master_t * master);

ethercat_device * clone_from_prototype(ethercat_device * proto, 
                                       ethercat_device_config * conf,
                                       ec_master_t * master,
                                       ec_domain_t * domain);

void initialize_chain(ethercat_device_config * chain, ethercat_device * devices, 
                      ec_master_t * master, ec_domain_t * domain);

