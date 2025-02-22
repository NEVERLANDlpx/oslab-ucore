## Challenge 2 ：任意大小的内存单元slub分配算法

任务：slub算法，实现两层架构的高效内存单元分配，第一层是基于页大小的内存分配，第二层是在第一层基础上实现基于任意大小的内存分配。可简化实现，能够体现其主体思想即可。

### SLUB 分配器设计

#### 1. **Cache 结构**
- 创建一系列大小为 2 的指数级别的 `cache`，以支持灵活的内存分配。
- `cache` 大小范围：
  - 从 \(2^4\) 到 \(2^{11}\)，即从 16B 到 2048B（2KB）。

#### 2. **内存分配逻辑**
- **请求内存大于 \(2^{11}\)（2048B）**：
  - 当请求的内存大小大于 2048B 时，系统将分配一个新的页面，页面大小为 4KB（4096B）。
  
- **请求内存小于或等于 \(2^{11}\)（2048B）**：
  - 当请求的内存大小小于或等于 2048B，系统会检查预定义的 `cache` 列表，找到第一个大于或等于请求大小的 `cache`。
  - 例如，若请求 40B，系统将从 64B 的 `cache` 中分配内存。

#### 3. **Cache 大小列表**
- `cache` 大小（以字节为单位）：
  - \(2^4 = 16B\)
  - \(2^5 = 32B\)
  - \(2^6 = 64B\)
  - \(2^7 = 128B\)
  - \(2^8 = 256B\)
  - \(2^9 = 512B\)
  - \(2^{10} = 1024B\)
  - \(2^{11} = 2048B\)

#### 4. **内存管理**
- 每个 `cache` 维护其内存块的使用状态，采用链表或位图来跟踪空闲和已分配内存块。
- 分配和释放内存块时，会更新相关 `cache` 的状态。
