// Linux Platform Device Driver for the ADC Controller for DE-Series Boards component

#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt

#include <linux/module.h>
#include <linux/platform_device.h>
#include <linux/mod_devicetable.h>
#include <linux/types.h>
#include <linux/io.h>
#include <linux/mutex.h>
#include <linux/miscdevice.h>
#include <linux/fs.h>
#include <linux/kernel.h>
#include <linux/uaccess.h>

//-----------------------------------------------------------------------
// Register Offsets
//-----------------------------------------------------------------------
// Define individual register offsets
#define REG_SAMPLE_SINGLE_OFFSET 0x00
#define REG_SAMPLE_DIFF_OFFSET 0x20
#define REG_CONFIG_SINGLE_OFFSET 0x40
#define REG_CONFIG_DIFF_OFFSET 0x44
// Memory span of all registers (used or not) in the component
#define SPAN 0x80


//-----------------------------------------------------------------------
// Device structure
//-----------------------------------------------------------------------
/**
 * struct adc_platform_dev - Private adc_platform device struct.
 * @miscdev: miscdevice used to create a char device for the adc_platform
 *           component
 * @base_addr: Base address of the adc_platform component
 * @lock: mutex used to prevent concurrent writes to the adc_platform component
 *
 * An adc_platform struct gets created for each adc_platform component in the
 * system.
 */
struct adc_platform_dev {
    struct miscdevice miscdev;
    void __iomem *base_addr;
    struct mutex lock;
};
/**
 * struct dev_reg_kind_attribute - Struct to store attributes for registers of
 *                                 a similar kind.
 * @attr: Normal device attribute struct
 * @reg_offset: Offset to the specific register being represented
 */
struct dev_reg_kind_attribute {
    struct device_attribute attr;
    unsigned int reg_offset;
};


//-----------------------------------------------------------------------
// Register kind: ADC channel (RO)
//-----------------------------------------------------------------------

/**
 * channel_show() - Report the ADC channel's value to userspace.
 * @dev: Device structure for the adc_platform component. This device struct is
 *       embedded in the adc_platform's platform device struct.
 * @attr: Unused.
 * @buf: Output buffer, passed to userspace.
 *
 * Return: The number of bytes read.
 */
static ssize_t channel_show(struct device *dev,
        struct device_attribute *attr, char *buf)
{
    struct adc_platform_dev *priv = dev_get_drvdata(dev);
    struct dev_reg_kind_attribute *channel_reg_attr
        = container_of(attr, struct dev_reg_kind_attribute, attr);
    unsigned int sample = ioread32(priv->base_addr + channel_reg_attr->reg_offset);
    return scnprintf(buf, PAGE_SIZE, "%u\n", sample);
}


//-----------------------------------------------------------------------
// Register kind: sample config (RW)
//-----------------------------------------------------------------------

/**
 * config_show() - Report the ADC platform's channel configuration to
 *                 userspace.
 * @dev: Device structure for the adc_platform component. This device struct is
 *       embedded in the adc_platform's platform device struct.
 * @attr: Unused.
 * @buf: Output buffer, passed to userspace.
 *
 * Return: The number of bytes read.
 */
static ssize_t config_show(struct device *dev,
        struct device_attribute *attr, char *buf)
{
    struct adc_platform_dev *priv = dev_get_drvdata(dev);
    struct dev_reg_kind_attribute *channel_reg_attr
        = container_of(attr, struct dev_reg_kind_attribute, attr);
    unsigned int config = ioread32(priv->base_addr + channel_reg_attr->reg_offset);
    return scnprintf(buf, PAGE_SIZE, "0x%02X\n", config);
}

/**
 * config_store() - Set the ADC platform's channel configuration from
 *                  userspace.
 * @dev: Device structure for the adc_platform component. This device struct is
 *       embedded in the adc_platform's platform device struct.
 * @attr: Unused.
 * @buf: Input buffer, passed from userspace.
 * @size: The number of bytes being written. Unused.
 *
 * Return: The number of bytes stored. Always equal to number of bytes written.
 */
static ssize_t config_store(struct device *dev,
        struct device_attribute *attr, const char *buf, size_t size)
{
    struct adc_platform_dev *priv = dev_get_drvdata(dev);
    struct dev_reg_kind_attribute *channel_reg_attr
        = container_of(attr, struct dev_reg_kind_attribute, attr);
    // Parse the string we received as a u8
    u8 config;
    int ret = kstrtou8(buf, 0, &config);
    if (ret < 0) {
        return ret;
    }
    // Write the resulting value, and return the number of bytes we consumed
    iowrite32(config, priv->base_addr + channel_reg_attr->reg_offset);
    return size;
}


//-----------------------------------------------------------------------
// sysfs Attributes
//-----------------------------------------------------------------------
#define DEVICE_ATTR_RO_KIND(_name, _kind, _reg_offset) \
struct dev_reg_kind_attribute dev_attr_##_name = \
    { __ATTR(_name, 0444, _kind##_show, NULL), _reg_offset }
#define DEVICE_ATTR_RW_KIND(_name, _kind, _reg_offset) \
struct dev_reg_kind_attribute dev_attr_##_name = \
    { __ATTR(_name, 0644, _kind##_show, _kind##_store), _reg_offset }
// Define sysfs attributes
// Read-only channel outputs
static DEVICE_ATTR_RO_KIND(ch_single_0, channel, REG_SAMPLE_SINGLE_OFFSET+0x00);
static DEVICE_ATTR_RO_KIND(ch_single_1, channel, REG_SAMPLE_SINGLE_OFFSET+0x04);
static DEVICE_ATTR_RO_KIND(ch_single_2, channel, REG_SAMPLE_SINGLE_OFFSET+0x08);
static DEVICE_ATTR_RO_KIND(ch_single_3, channel, REG_SAMPLE_SINGLE_OFFSET+0x0C);
static DEVICE_ATTR_RO_KIND(ch_single_4, channel, REG_SAMPLE_SINGLE_OFFSET+0x10);
static DEVICE_ATTR_RO_KIND(ch_single_5, channel, REG_SAMPLE_SINGLE_OFFSET+0x14);
static DEVICE_ATTR_RO_KIND(ch_single_6, channel, REG_SAMPLE_SINGLE_OFFSET+0x18);
static DEVICE_ATTR_RO_KIND(ch_single_7, channel, REG_SAMPLE_SINGLE_OFFSET+0x1C);
static DEVICE_ATTR_RO_KIND(ch_diff_Apos, channel, REG_SAMPLE_DIFF_OFFSET+0x00);
static DEVICE_ATTR_RO_KIND(ch_diff_Aneg, channel, REG_SAMPLE_DIFF_OFFSET+0x04);
static DEVICE_ATTR_RO_KIND(ch_diff_Bpos, channel, REG_SAMPLE_DIFF_OFFSET+0x08);
static DEVICE_ATTR_RO_KIND(ch_diff_Bneg, channel, REG_SAMPLE_DIFF_OFFSET+0x0C);
static DEVICE_ATTR_RO_KIND(ch_diff_Cpos, channel, REG_SAMPLE_DIFF_OFFSET+0x10);
static DEVICE_ATTR_RO_KIND(ch_diff_Cneg, channel, REG_SAMPLE_DIFF_OFFSET+0x14);
static DEVICE_ATTR_RO_KIND(ch_diff_Dpos, channel, REG_SAMPLE_DIFF_OFFSET+0x18);
static DEVICE_ATTR_RO_KIND(ch_diff_Dneg, channel, REG_SAMPLE_DIFF_OFFSET+0x1C);
// Read-write config registers
static DEVICE_ATTR_RW_KIND(config_single, config, REG_CONFIG_SINGLE_OFFSET);
static DEVICE_ATTR_RW_KIND(config_diff,   config, REG_CONFIG_DIFF_OFFSET);

// Create an attribute group so the device core can export the attributes for
// us.
static struct attribute *adc_platform_attrs[] = {
    &dev_attr_ch_single_0.attr.attr,
    &dev_attr_ch_single_1.attr.attr,
    &dev_attr_ch_single_2.attr.attr,
    &dev_attr_ch_single_3.attr.attr,
    &dev_attr_ch_single_4.attr.attr,
    &dev_attr_ch_single_5.attr.attr,
    &dev_attr_ch_single_6.attr.attr,
    &dev_attr_ch_single_7.attr.attr,
    &dev_attr_ch_diff_Apos.attr.attr,
    &dev_attr_ch_diff_Aneg.attr.attr,
    &dev_attr_ch_diff_Bpos.attr.attr,
    &dev_attr_ch_diff_Bneg.attr.attr,
    &dev_attr_ch_diff_Cpos.attr.attr,
    &dev_attr_ch_diff_Cneg.attr.attr,
    &dev_attr_ch_diff_Dpos.attr.attr,
    &dev_attr_ch_diff_Dneg.attr.attr,
    &dev_attr_config_single.attr.attr,
    &dev_attr_config_diff.attr.attr,
    NULL,
};
ATTRIBUTE_GROUPS(adc_platform);


//-----------------------------------------------------------------------
// File Operations read()
//-----------------------------------------------------------------------
/**
 * adc_platform_read() - Read method for the adc_platform char device
 * @file: Pointer to the char device file struct.
 * @buf: User-space buffer to read the value into.
 * @count: The number of bytes being requested.
 * @offset: The byte offset in the file being read from.
 *
 * Return: On success, the number of bytes written is returned and the offset
 *         @offset is advanced by this number. On error, a negative error value
 *         is returned.
 */
static ssize_t adc_platform_read(struct file *file, char __user *buf,
    size_t count, loff_t *offset)
{
    size_t ret;
    u32 val;

    loff_t pos = *offset;

    /* Get the device's private data from the file struct's private_data field.
     * The private_data field is equal to the miscdev field in the
     * adc_platform_dev struct. container_of returns the adc_platform_dev struct
     * that contains the miscdev in private_data.
     */
    struct adc_platform_dev *priv = container_of(file->private_data,
            struct adc_platform_dev, miscdev);

    // Check file offset to make sure we are reading to a valid location.
    if (pos < 0) {
        // We can't read from a negative file position.
        return -EINVAL;
    }
    if (pos >= SPAN) {
        // We can't read from a position past the end of our device.
        return 0;
    }
    if ((pos % 0x4) != 0) {
        /* Prevent unaligned access. Even though the hardware technically
         * supports unaligned access, we want to ensure that we only access
         * 32-bit-aligned addresses because our registers are 32-bit-aligned.
         */
        pr_warn("adc_platform_read: unaligned access\n");
        return -EFAULT;
    }

    // If the user didn't request any bytes, don't return any bytes :)
    if (count == 0) {
        return 0;
    }

    // Read the value at offset pos.
    val = ioread32(priv->base_addr + pos);

    ret = copy_to_user(buf, &val, sizeof(val));
    if (ret == sizeof(val)) {
        // Nothing was copied to the user.
        pr_warn("adc_platform_read: nothing copied\n");
        return -EFAULT;
    }

    // Increment the file offset by the number of bytes we read.
    *offset = pos + sizeof(val);

    return sizeof(val);
}

//-----------------------------------------------------------------------
// File Operations write()
//-----------------------------------------------------------------------
/**
 * adc_platform_write() - Write method for the adc_platform char device
 * @file: Pointer to the char device file struct.
 * @buf: User-space buffer to read the value from.
 * @count: The number of bytes being written.
 * @offset: The byte offset in the file being written to.
 *
 * Return: On success, the number of bytes written is returned and the offset
 *         @offset is advanced by this number. On error, a negative error value
 *         is returned.
 */
static ssize_t adc_platform_write(struct file *file, const char __user *buf,
        size_t count, loff_t *offset)
{
    size_t ret;
    u32 val;

    loff_t pos = *offset;

    /* Get the device's private data from the file struct's private_data field.
     * The private_data field is equal to the miscdev field in the
     * adc_platform_dev struct. container_of returns the adc_platform_dev
     * struct that contains the miscdev in private_data.
     */
    struct adc_platform_dev *priv = container_of(file->private_data,
            struct adc_platform_dev, miscdev);

    // Check file offset to make sure we are writing to a valid location.
    if (pos < 0) {
        // We can't write to a negative file position.
        return -EINVAL;
    }
    if (pos >= SPAN) {
        // We can't write to a position past the end of our device.
        return 0;
    }
    if ((pos % 0x4) != 0) {
        /* Prevent unaligned access. Even though the hardware technically
         * supports unaligned access, we want to ensure that we only access
         * 32-bit-aligned addresses because our registers are 32-bit-aligned.
         */
        pr_warn("adc_platform_write: unaligned access\n");
        return -EFAULT;
    }

    // If the user didn't request to write anything, return 0.
    if (count == 0) {
        return 0;
    }

    mutex_lock(&priv->lock);

    ret = copy_from_user(&val, buf, sizeof(val));
    if (ret == sizeof(val)) {
        // Nothing was copied from the user.
        pr_warn("adc_platform_write: nothing copied from user space\n");
        ret = -EFAULT;
        goto unlock;
    }

    // Write the value we were given at the address offset given by pos.
    iowrite32(val, priv->base_addr + pos);

    // Increment the file offset by the number of bytes we wrote.
    *offset = pos + sizeof(val);

    // Return the number of bytes we wrote.
    ret = sizeof(val);

unlock:
    mutex_unlock(&priv->lock);
    return ret;
}

//-----------------------------------------------------------------------
// File Operations Supported
//-----------------------------------------------------------------------
/**
 * adc_platform_fops - File operations supported by the adc_platform driver
 * @owner: The adc_platform driver owns the file operations; this ensures that
 *         the driver can't be removed while the character device is still in
 *         use.
 * @read: The read function.
 * @write: The write function.
 * @llseek: We use the kernel's default_llseek() function; this allows users to
 *          change what position they are writing/reading to/from.
 */
static const struct file_operations adc_platform_fops = {
    .owner = THIS_MODULE,
    .read = adc_platform_read,
    .write = adc_platform_write,
    .llseek = default_llseek,
};


//-----------------------------------------------------------------------
// Platform Driver Probe (Initialization) Function
//-----------------------------------------------------------------------
/**
 * adc_platform_probe() - Initialize device when a match is found
 * @pdev: Platform device structure associated with our adc_platform device;
 *        pdev is automatically created by the driver core based upon our
 *        adc_platform device tree node.
 *
 * When a device that is compatible with this adc_platform driver is found, the
 * driver's probe function is called. This probe function gets called by the
 * kernel when an adc_platform device is found in the device tree.
 */
static int adc_platform_probe(struct platform_device *pdev)
{
    struct adc_platform_dev *priv;
    int ret;

    /* Allocate kernel memory for the adc_platform device and set it to 0.
     * GFP_KERNEL specifies that we are allocating normal kernel RAM; see the
     * kmalloc documentation for more info. The allocated memory is
     * automatically freed when the device is removed.
     */
    priv = devm_kzalloc(&pdev->dev, sizeof(struct adc_platform_dev), GFP_KERNEL);
    if (!priv) {
        pr_err("Failed to allocate kernel memory for adc_platform\n");
        return -ENOMEM;
    }

    /* Request and remap the device's memory region. Requesting the region
     * makes sure nobody else can use that memory. The memory is remapped into
     * the kernel's virtual address space becuase we don't have access to
     * physical memory locations.
     */
    priv->base_addr = devm_platform_ioremap_resource(pdev, 0);
    if (IS_ERR(priv->base_addr)) {
        pr_err("Failed to request/remap platform device resource (adc_platform)\n");
        return PTR_ERR(priv->base_addr);
    }

    // Initialize the misc device parameters
    priv->miscdev.minor = MISC_DYNAMIC_MINOR;
    priv->miscdev.name = "adc_platform";
    priv->miscdev.parent = &pdev->dev;
    priv->miscdev.groups = adc_platform_groups;

    // Register the misc device; this creates a char dev at /dev/adc_platform
    ret = misc_register(&priv->miscdev);
    if (ret) {
        pr_err("Failed to register misc device for adc_platform\n");
        return ret;
    }

    // Attach the adc_platform's private data to the platform device's struct.
    platform_set_drvdata(pdev, priv);

    pr_info("adc_platform probed successfully\n");
    return 0;
}

//-----------------------------------------------------------------------
// Platform Driver Remove Function
//-----------------------------------------------------------------------
/**
 * adc_platform_remove() - Remove an adc_platform device.
 * @pdev: Platform device structure associated with our adc_platform device.
 *
 * This function is called when an adc_platform devicee is removed or the driver
 * is removed.
 */
static int adc_platform_remove(struct platform_device *pdev)
{
    // Get the adc_platform's private data from the platform device.
    struct adc_platform_dev *priv = platform_get_drvdata(pdev);

    // Deregister the misc device and remove the /dev/adc_platform file.
    misc_deregister(&priv->miscdev);

    pr_info("adc_platform removed successfully\n");

    return 0;
}

//-----------------------------------------------------------------------
// Compatible Match String
//-----------------------------------------------------------------------
/* Define the compatible property used for matching devices to this driver,
 * then add our device id structure to the kernel's device table. For a device
 * to be matched with this driver, its device tree node must use the same
 * compatible string as defined here.
 */
static const struct of_device_id adc_platform_of_match[] = {
    // NOTE: This .compatible string must be identical to the .compatible
    // string in the Device Tree Node for adc_platform
    { .compatible = "lr,adcPlatform", },
    { }
};
MODULE_DEVICE_TABLE(of, adc_platform_of_match);

//-----------------------------------------------------------------------
// Platform Driver Structure
//-----------------------------------------------------------------------
/**
 * struct adc_platform_driver - Platform driver struct for the adc_platform
 *                              driver
 * @probe: Function that's called when a device is found
 * @remove: Function that's called when a device is removed
 * @driver.owner: Which module owns this driver
 * @driver.name: Name of the adc_platform driver
 * @driver.of_match_table: Device tree match table
 * @driver.dev_groups: adc_platform sysfs attribute group; this allows the
 *                     driver core to create the attribute(s) without race
 *                     conditions.
 */
static struct platform_driver adc_platform_driver = {
    .probe = adc_platform_probe,
    .remove = adc_platform_remove,
    .driver = {
        .owner = THIS_MODULE,
        .name = "adc_platform",
        .of_match_table = adc_platform_of_match,
        .dev_groups = adc_platform_groups,
    },
};

/* We don't need to do anything special in module init/exit. This macro
 * automatically handles module init/exit.
 */
module_platform_driver(adc_platform_driver);

MODULE_LICENSE("Dual MIT/GPL");
MODULE_AUTHOR("Lucas Ritzdorf");  // Adapted from Ross Snider and Trevor Vannoy's Echo Driver
MODULE_DESCRIPTION("Custom DE10-Nano ADC controller driver");
MODULE_VERSION("1.0");
