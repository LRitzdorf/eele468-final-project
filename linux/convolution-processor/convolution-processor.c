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
#define REG_WETDRYMIX_OFFSET 0x0
#define REG_VOLUME_OFFSET 0x4
#define REG_ENABLE_OFFSET 0x8
// Memory span of all registers (used or not) in the component
#define SPAN 0x10


//-----------------------------------------------------------------------
// Device structure
//-----------------------------------------------------------------------
/**
 * struct conv_proc_dev - Private conv_proc device struct.
 * @miscdev: miscdevice used to create a char device for the conv_proc
 *           component
 * @base_addr: Base address of the conv_proc component
 * @lock: mutex used to prevent concurrent writes to the conv_proc component
 *
 * A conv_proc struct gets created for each conv_proc component in the
 * system.
 */
struct conv_proc_dev {
    struct miscdevice miscdev;
    void __iomem *base_addr;
    struct mutex lock;
};


//-----------------------------------------------------------------------
// Register: wetDryMix parameter (RW)
//-----------------------------------------------------------------------

/**
 * wetDryMix_show() - Report the convolution processor's wet/dry mix parameter
 *                    to userspace.
 * @dev: Device structure for the conv_proc component. This device struct is
 *       embedded in the conv_proc's platform device struct.
 * @attr: Unused.
 * @buf: Output buffer, passed to userspace.
 *
 * Return: The number of bytes read.
 */
static ssize_t wetDryMix_show(struct device *dev,
        struct device_attribute *attr, char *buf)
{
    struct conv_proc_dev *priv = dev_get_drvdata(dev);
    unsigned int wetDryMix = ioread32(priv->base_addr + REG_WETDRYMIX_OFFSET);
    return scnprintf(buf, PAGE_SIZE, "%u\n", wetDryMix);
}

/**
 * wetDryMix_store() - Set the convolution processor's wet/dry mix parameter
 *                     from userspace.
 * @dev: Device structure for the conv_proc component. This device struct is
 *       embedded in the conv_proc's platform device struct.
 * @attr: Unused.
 * @buf: Input buffer, passed from userspace.
 * @size: The number of bytes being written. Unused.
 *
 * Return: The number of bytes stored. Always equal to number of bytes written.
 */
static ssize_t wetDryMix_store(struct device *dev,
        struct device_attribute *attr, const char *buf, size_t size)
{
    struct conv_proc_dev *priv = dev_get_drvdata(dev);
    // Parse the string we received as an unsigned integer
    u16 wetDryMix;
    int ret = kstrtou16(buf, 0, &wetDryMix);
    if (ret < 0) {
        return ret;
    }
    // Write the resulting value, and return the number of bytes we consumed
    iowrite32(wetDryMix, priv->base_addr + REG_WETDRYMIX_OFFSET);
    return size;
}


//-----------------------------------------------------------------------
// Register: volume control (RW)
//-----------------------------------------------------------------------

/**
 * volume_show() - Report the convolution processor's volume level to
 *                 userspace.
 * @dev: Device structure for the conv_proc component. This device struct is
 *       embedded in the conv_proc's platform device struct.
 * @attr: Unused.
 * @buf: Output buffer, passed to userspace.
 *
 * Return: The number of bytes read.
 */
static ssize_t volume_show(struct device *dev,
        struct device_attribute *attr, char *buf)
{
    struct conv_proc_dev *priv = dev_get_drvdata(dev);
    unsigned int volume = ioread32(priv->base_addr + REG_VOLUME_OFFSET);
    return scnprintf(buf, PAGE_SIZE, "%u\n", volume);
}

/**
 * volume_store() - Set the convolution processor's volume level from
 *                  userspace.
 * @dev: Device structure for the conv_proc component. This device struct is
 *       embedded in the conv_proc's platform device struct.
 * @attr: Unused.
 * @buf: Input buffer, passed from userspace.
 * @size: The number of bytes being written. Unused.
 *
 * Return: The number of bytes stored. Always equal to number of bytes written.
 */
static ssize_t volume_store(struct device *dev,
        struct device_attribute *attr, const char *buf, size_t size)
{
    struct conv_proc_dev *priv = dev_get_drvdata(dev);
    // Parse the string we received as a boolean
    u16 volume;
    int ret = kstrtou16(buf, 0, &volume);
    if (ret < 0) {
        return ret;
    }
    // Write the resulting value, and return the number of bytes we consumed
    iowrite32(volume, priv->base_addr + REG_VOLUME_OFFSET);
    return size;
}


//-----------------------------------------------------------------------
// Register: enable control (RW)
//-----------------------------------------------------------------------

/**
 * enable_show() - Report the convolution processor's enable state to
 *                 userspace.
 * @dev: Device structure for the conv_proc component. This device struct is
 *       embedded in the conv_proc's platform device struct.
 * @attr: Unused.
 * @buf: Output buffer, passed to userspace.
 *
 * Return: The number of bytes read.
 */
static ssize_t enable_show(struct device *dev,
        struct device_attribute *attr, char *buf)
{
    struct conv_proc_dev *priv = dev_get_drvdata(dev);
    unsigned int enable = ioread32(priv->base_addr + REG_ENABLE_OFFSET);
    return scnprintf(buf, PAGE_SIZE, "%d\n", enable);
}

/**
 * enable_store() - Set the convolution processor's enable state from
 *                  userspace.
 * @dev: Device structure for the conv_proc component. This device struct is
 *       embedded in the conv_proc's platform device struct.
 * @attr: Unused.
 * @buf: Input buffer, passed from userspace.
 * @size: The number of bytes being written. Unused.
 *
 * Return: The number of bytes stored. Always equal to number of bytes written.
 */
static ssize_t enable_store(struct device *dev,
        struct device_attribute *attr, const char *buf, size_t size)
{
    struct conv_proc_dev *priv = dev_get_drvdata(dev);
    // Parse the string we received as a boolean
    bool enable;
    int ret = kstrtobool(buf, &enable);
    if (ret < 0) {
        return ret;
    }
    // Write the resulting value, and return the number of bytes we consumed
    iowrite32(enable, priv->base_addr + REG_ENABLE_OFFSET);
    return size;
}


//-----------------------------------------------------------------------
// sysfs Attributes
//-----------------------------------------------------------------------
// Define sysfs attributes
static DEVICE_ATTR_RW(wetDryMix);
static DEVICE_ATTR_RW(volume);
static DEVICE_ATTR_RW(enable);

// Create an attribute group so the device core can export the attributes for
// us.
static struct attribute *conv_proc_attrs[] = {
    &dev_attr_wetDryMix.attr,
    &dev_attr_volume.attr,
    &dev_attr_enable.attr,
    NULL,
};
ATTRIBUTE_GROUPS(conv_proc);


//-----------------------------------------------------------------------
// File Operations read()
//-----------------------------------------------------------------------
/**
 * conv_proc_read() - Read method for the conv_proc char device
 * @file: Pointer to the char device file struct.
 * @buf: User-space buffer to read the value into.
 * @count: The number of bytes being requested.
 * @offset: The byte offset in the file being read from.
 *
 * Return: On success, the number of bytes written is returned and the offset
 *         @offset is advanced by this number. On error, a negative error value
 *         is returned.
 */
static ssize_t conv_proc_read(struct file *file, char __user *buf,
    size_t count, loff_t *offset)
{
    size_t ret;
    u32 val;

    loff_t pos = *offset;

    /* Get the device's private data from the file struct's private_data field.
     * The private_data field is equal to the miscdev field in the
     * conv_proc_dev struct. container_of returns the conv_proc_dev struct
     * that contains the miscdev in private_data.
     */
    struct conv_proc_dev *priv = container_of(file->private_data,
            struct conv_proc_dev, miscdev);

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
        pr_warn("conv_proc_read: unaligned access\n");
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
        pr_warn("conv_proc_read: nothing copied\n");
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
 * conv_proc_write() - Write method for the conv_proc char device
 * @file: Pointer to the char device file struct.
 * @buf: User-space buffer to read the value from.
 * @count: The number of bytes being written.
 * @offset: The byte offset in the file being written to.
 *
 * Return: On success, the number of bytes written is returned and the offset
 *         @offset is advanced by this number. On error, a negative error value
 *         is returned.
 */
static ssize_t conv_proc_write(struct file *file, const char __user *buf,
        size_t count, loff_t *offset)
{
    size_t ret;
    u32 val;

    loff_t pos = *offset;

    /* Get the device's private data from the file struct's private_data field.
     * The private_data field is equal to the miscdev field in the
     * conv_proc_dev struct. container_of returns the conv_proc_dev
     * struct that contains the miscdev in private_data.
     */
    struct conv_proc_dev *priv = container_of(file->private_data,
            struct conv_proc_dev, miscdev);

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
        pr_warn("conv_proc_write: unaligned access\n");
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
        pr_warn("conv_proc_write: nothing copied from user space\n");
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
 * conv_proc_fops - File operations supported by the conv_proc driver
 * @owner: The conv_proc driver owns the file operations; this ensures that
 *         the driver can't be removed while the character device is still in
 *         use.
 * @read: The read function.
 * @write: The write function.
 * @llseek: We use the kernel's default_llseek() function; this allows users to
 *          change what position they are writing/reading to/from.
 */
static const struct file_operations conv_proc_fops = {
    .owner = THIS_MODULE,
    .read = conv_proc_read,
    .write = conv_proc_write,
    .llseek = default_llseek,
};


//-----------------------------------------------------------------------
// Platform Driver Probe (Initialization) Function
//-----------------------------------------------------------------------
/**
 * conv_proc_probe() - Initialize device when a match is found
 * @pdev: Platform device structure associated with our conv_proc device;
 *        pdev is automatically created by the driver core based upon our
 *        conv_proc device tree node.
 *
 * When a device that is compatible with this conv_proc driver is found, the
 * driver's probe function is called. This probe function gets called by the
 * kernel when an conv_proc device is found in the device tree.
 */
static int conv_proc_probe(struct platform_device *pdev)
{
    struct conv_proc_dev *priv;
    int ret;

    /* Allocate kernel memory for the conv_proc device and set it to 0.
     * GFP_KERNEL specifies that we are allocating normal kernel RAM; see the
     * kmalloc documentation for more info. The allocated memory is
     * automatically freed when the device is removed.
     */
    priv = devm_kzalloc(&pdev->dev, sizeof(struct conv_proc_dev), GFP_KERNEL);
    if (!priv) {
        pr_err("Failed to allocate kernel memory for conv_proc\n");
        return -ENOMEM;
    }

    /* Request and remap the device's memory region. Requesting the region
     * makes sure nobody else can use that memory. The memory is remapped into
     * the kernel's virtual address space becuase we don't have access to
     * physical memory locations.
     */
    priv->base_addr = devm_platform_ioremap_resource(pdev, 0);
    if (IS_ERR(priv->base_addr)) {
        pr_err("Failed to request/remap platform device resource (conv_proc)\n");
        return PTR_ERR(priv->base_addr);
    }

    // Initialize the misc device parameters
    priv->miscdev.minor = MISC_DYNAMIC_MINOR;
    priv->miscdev.name = "convolution_processor";
    priv->miscdev.parent = &pdev->dev;
    priv->miscdev.groups = conv_proc_groups;

    // Register the misc device; this creates a char dev at /dev/convolution_processor
    ret = misc_register(&priv->miscdev);
    if (ret) {
        pr_err("Failed to register misc device for convolution_processor\n");
        return ret;
    }

    // Attach the conv_proc's private data to the platform device's struct.
    platform_set_drvdata(pdev, priv);

    pr_info("convolution_processor probed successfully\n");
    return 0;
}

//-----------------------------------------------------------------------
// Platform Driver Remove Function
//-----------------------------------------------------------------------
/**
 * conv_proc_remove() - Remove a conv_proc device.
 * @pdev: Platform device structure associated with our conv_proc device.
 *
 * This function is called when a conv_proc device is removed or the driver
 * is removed.
 */
static int conv_proc_remove(struct platform_device *pdev)
{
    // Get the conv_proc's private data from the platform device.
    struct conv_proc_dev *priv = platform_get_drvdata(pdev);

    // Deregister the misc device and remove the /dev/conv_processor file.
    misc_deregister(&priv->miscdev);

    pr_info("convolution_processor removed successfully\n");

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
static const struct of_device_id conv_proc_of_match[] = {
    // NOTE: This .compatible string must be identical to the .compatible
    // string in the Device Tree Node for conv_proc
    { .compatible = "lr,convolutionProcessor", },
    { }
};
MODULE_DEVICE_TABLE(of, conv_proc_of_match);

//-----------------------------------------------------------------------
// Platform Driver Structure
//-----------------------------------------------------------------------
/**
 * struct conv_proc_driver - Platform driver struct for the conv_proc
 *                             driver
 * @probe: Function that's called when a device is found
 * @remove: Function that's called when a device is removed
 * @driver.owner: Which module owns this driver
 * @driver.name: Name of the conv_proc driver
 * @driver.of_match_table: Device tree match table
 * @driver.dev_groups: conv_proc sysfs attribute group; this allows the
 *                     driver core to create the attribute(s) without race
 *                     conditions.
 */
static struct platform_driver conv_proc_driver = {
    .probe = conv_proc_probe,
    .remove = conv_proc_remove,
    .driver = {
        .owner = THIS_MODULE,
        .name = "convolution_processor",
        .of_match_table = conv_proc_of_match,
        .dev_groups = conv_proc_groups,
    },
};

/* We don't need to do anything special in module init/exit. This macro
 * automatically handles module init/exit.
 */
module_platform_driver(conv_proc_driver);

MODULE_LICENSE("Dual MIT/GPL");
MODULE_AUTHOR("Lucas Ritzdorf");  // Adapted from Ross Snider and Trevor Vannoy's Echo Driver
MODULE_DESCRIPTION("Driver for convolution audio processor");
MODULE_VERSION("1.0");
