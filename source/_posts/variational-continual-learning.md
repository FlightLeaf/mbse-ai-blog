---
title: 论文笔记 | Variational Continual Learning：用变分推断对抗灾难性遗忘
date: 2026-08-06 12:00:00
categories:
  - 科研日常
tags:
  - 持续学习
  - 变分推断
  - 贝叶斯深度学习
  - 论文笔记
mathjax: true
---

> 持续学习（Continual Learning）是当前深度学习中极具挑战的问题之一：模型在陆续到来的任务上训练时，往往会"学一个新任务、忘掉旧任务"，这就是著名的**灾难性遗忘**（Catastrophic Forgetting）。这篇 ICLR 2018 的论文给出了一个优雅的回答——**持续学习本质上就是贝叶斯推断**。

## 基本信息

| 项目 | 内容 |
| ---- | ---- |
| 论文 | Variational Continual Learning |
| 作者 | Cuong V. Nguyen, Yingzhen Li, Thang D. Bui, Richard E. Turner |
| 单位 | University of Cambridge, Department of Engineering |
| 会议 | ICLR 2018 |
| arXiv | [1710.10628](https://arxiv.org/abs/1710.10628) |
| 代码 | [variational-continual-learning](https://github.com/nvcuong/variational-continual-learning) |

## 1. 问题背景：灾难性遗忘

深度神经网络在**非独立同分布**的数据流上持续学习时，会面临一个核心矛盾：

- **过强的可塑性**（Plasticity）→ 模型过度适应新数据，遗忘旧任务 → 灾难性遗忘（McCloskey & Cohen, 1989）
- **过强的稳定性**（Stability）→ 模型无法适应新任务

此前的主流方法是**正则化最大似然**，即在损失中加入对参数变化的惩罚，代表性工作包括：

- **EWC**（Elastic Weight Consolidation, Kirkpatrick et al., 2017）：用 Fisher 信息矩阵近似参数重要性，对重要参数施加强正则
- **SI**（Synaptic Intelligence, Zenke et al., 2017）：根据训练过程中梯度的变化率估计参数重要性
- **Laplace Propagation**（Smola et al., 2004）：在每步做拉普拉斯近似

这些方法都带有一个需要人工调节的超参数 $\lambda$（正则强度），且只保留参数的点估计，不确定性信息是缺失的。

## 2. 核心思想：贝叶斯推断就是持续学习

论文的出发点非常简洁：**贝叶斯推断天然就是持续的**。

假设参数先验为 $p(\theta)$，观察到 $T$ 个数据集 $D_{1:T}$ 后，后验为：

$$p(\theta|D_{1:T}) \propto p(\theta)\prod_{t=1}^{T} p(D_t|\theta) = p(\theta|D_{1:T-1})\, p(D_T|\theta)$$

关键在于这个**递归结构**：看到第 $T$ 个数据集的后验 = 看到前 $T-1$ 个数据集的后验 × 新数据的似然。也就是说，**旧数据对参数的约束全部编码在了"上一个后验"里**，新任务到来时只需把上一个后验当作先验使用即可——不需要回顾旧数据，旧知识也不会被冲掉。

这恰恰解决了灾难性遗忘的核心矛盾：

- 旧后验中方差小的参数（被旧数据约束死的参数）难以改变 → 稳定性
- 方差大的参数仍可自由更新 → 可塑性

 💡 **"Projection"视角**：每一步都是把不可处理的真实后验投影（Project）到一个可处理的近似分布族上，即 $q_t(\theta) = \mathrm{proj}\big(q_{t-1}(\theta)p(D_t|\theta)\big)$。不同的投影算子对应不同的经典算法：KL 最小化 → 在线变分推断；矩匹配 → 假定密度滤波（ADF）；重要性采样 → 序列蒙特卡洛（SMC）。

## 3. VCL：变分持续学习

既然精确贝叶斯推断不可处理，VCL 选择用**在线变分推断**（Online VI, Ghahramani & Attias, 2000; Sato, 2001）作为投影算子，结合 Blundell et al. (2015) 的蒙特卡洛变分推断（Bayes by Backprop）训练深度网络。

每一步求解：

$$q_t(\theta) = \arg\min_{q \in \mathcal{Q}} \mathrm{KL}\Big( q(\theta) \,\Big\Vert\, \frac{1}{Z_t} q_{t-1}(\theta)\, p(D_t|\theta) \Big)$$

等价于最大化**负在线变分自由能**：

$$\mathcal{L}_t^{\mathrm{VCL}}(q_t) = \sum_{n=1}^{N_t} \mathbb{E}_{\theta \sim q_t}\big[\log p(y_t^{(n)}|\theta, x_t^{(n)})\big] - \mathrm{KL}\big(q_t(\theta)\Vert q_{t-1}(\theta)\big)$$

其中：

- 期望似然项用蒙特卡洛估计，配合**局部重参数化技巧**（Local Reparameterization Trick）计算梯度
- KL 项在分布族内可闭式求解

近似后验族采用**高斯平均场**：$q_t(\theta) = \prod_{d} \mathcal{N}(\mu_{t,d}, \sigma_{t,d}^2)$，训练等价于在每层权重上施加变分 Dropout（不确定性估计）。

**VCL 与 EWC/SI/LP 的关键区别：**

1. **无自由超参数**：目标函数中没有需要调参的 $\lambda$，超参数搜索在在线场景下是很尴尬的
2. **保留完整分布**：训练和测试时都对后验分布做平均，而不是只用一个点估计
3. **不确定性更好**：VI 比拉普拉斯近似、MAP 的不确定性估计质量更高

## 4. Coreset VCL：情景记忆增强

反复的投影会累积近似误差，可能导致模型"忘记"旧任务。为此论文引入**核心集**（Coreset）作为**情景记忆**（Episodic Memory）——从每个旧任务中保留少量代表性数据点，模拟人类回忆过去经历的能力。

> ⚠️ **核心集选择有两种策略**：
> - **随机采样**：从每个任务随机取 $K$ 个点
> - **K-center 算法**（Gonzalez, 1985）：贪心地选取覆盖整个输入空间的 $K$ 个点（保证分布分散）

Coreset VCL 的核心机制（见论文 Algorithm 1）：

1. 对**不在核心集中**的数据做变分递归更新：$\tilde{q}_t = \mathrm{proj}\big(\tilde{q}_{t-1}(\theta)\, p(D_t \cup C_{t-1}\backslash C_t|\theta)\big)$
2. 预测前，再把核心集数据“回放”一遍：$q_t = \mathrm{proj}\big(\tilde{q}_t(\theta)\, p(C_t|\theta)\big)$

直观理解：核心集相当于消息传递（Message Passing）中优先级最高的消息，在每步预测前重新"唤醒"旧记忆，从而缓解遗忘。

## 5. 判别模型与生成模型

VCL 是一个通用框架，论文在两类模型上验证：

### 判别模型（分类网络）

根据任务性质选择网络结构：

- **单头网络**（Single-head）：适用于输入分布变化而输出不变的任务（如 Permuted MNIST）
- **多头网络**（Multi-head）：共享底层 $\theta_S$，每个任务有自己的头网络 $\theta_t^H$（如 Split MNIST 的 0/1、2/3 等任务，输出空间不同）

多头结构的好处：新任务出现时，其头参数的后验直接初始化为先验，变分分布可以随任务**增量生长**，且只需更新当前任务涉及的头。

### 生成模型（VAE）

对 VAE 扩展时，不仅对参数 $\theta$ 做变分后验，还保留任务特定的编码器 $q_\phi(z|x)$。架构上选择**共享高层生成网络**（从中间表示 $h$ 生成 $x$ 的部分共享），每个任务私有的低层"头网络"（从隐变量 $z$ 生成 $h$）——这更符合"共享笔画等结构基元、任务决定高层语义"的直觉。

## 6. 实验与结果

### 6.1 判别模型

**Permuted MNIST**（10 个任务，每个任务对 MNIST 像素施加不同随机排列，单头网络）：

| 方法（任务 10 后平均准确率） | 准确率 |
| ---- | ---- |
| EWC（最优 $\lambda$） | 84% |
| SI（最优 $\lambda$） | 86% |
| LP（最优 $\lambda$） | 82% |
| **VCL** | **90%** |
| **VCL + Coreset（每任务 200 点）** | **93%** |
| VCL + Coreset（每任务 5000 点） | 95.5% |

注意 EWC/SI/LP 都经过了**详尽的超参数搜索**（"best $\lambda$"），而 VCL 是零调参的。另外单独使用 Coreset 效果很差，说明**核心集与变分后验的结合才是关键**——变分后验提供了"记忆骨架"，核心集负责"细节补充"。

**Split MNIST**（5 个二分类任务，多头网络）：

| 方法（5 任务后平均准确率） | 准确率 |
| ---- | ---- |
| EWC（最优 $\lambda$） | 63.1% |
| SI（最优 $\lambda$） | 98.9% |
| LP | 61.2% |
| **VCL** | **97.0%** |
| **VCL + Coreset** | **98.4%** |

**Split notMNIST**（5 个二分类任务，4 层网络）：VCL 达 92.0%，加随机核心集提升到 96%，与 SI（94%）持平或更好，显著超过 EWC（71%）和 LP（63%）。

### 6.2 生成模型

在 MNIST 数字（0-9 逐个任务到达）和 notMNIST 字符（A-J）生成任务上：

- **Naive VAE 直接灾难性失败**：只能生成最近任务的样本
- VCL 与 SI 的生成质量最佳，且 **VCL 在测试似然（Test-LL）和"分类器不确定性"两个指标上优于或持平 SI**，展现出更强的长期记忆
- LP/EWC 在任务差异大时（如从数字 0 到 1）性能显著退化

## 7. 个人思考

**这篇论文的贡献**，我认为不只是提出一个性能更好的方法，更重要的是**视角的转换**：它把持续学习重新放回贝叶斯框架中，让"旧知识如何保留"这个难题有了一个原则性的答案——后验就是记忆。相比之下 EWC 的 $\lambda$ 更像工程上的补丁，而 VCL 的超参数就是"没有超参数"。

几个值得注意的点：

1. **任务边界的假设**：VCL（及同期工作）假设任务切换时刻已知，且多头网络需要知道当前任务 ID（task oracle）。这与真实世界中"任务连续演化、无明确边界"的场景还有差距，论文也在摘要中强调了"existing tasks evolve over time and entirely new tasks emerge"的动机，但实验设置仍偏理想化。

2. **近似族的局限**：高斯平均场的表达能力有限，任务序列变长时，反复 KL 投影的误差积累（posterior collapse / 对不确定性估计的退化）仍是个问题。后续工作（如 Variational Continual Bayesian Meta-Learning、Bayesian Gradient-based 等方法）在这一点上做了改进。

3. **计算代价**：维护参数的完整分布（均值+方差）意味着参数量翻倍，训练时需要对权重采样，这在当时的大模型上代价不菲。不过近年来"先训练再贝叶斯化"（如 SWAG、Laplace 后验）的思路可以缓解这一点。

4. **核心集的现代视角**：Coreset 其实就是后来"经验回放（Experience Replay）"家族的前身，也是 memory-augmented continual learning 的雏形。当时随机采样与 K-center 差距不大，但后来的研究表明**基于梯度或不确定性的选择策略**能进一步提效。

5. **与贝叶斯在线学习的关系**：VCL 与流式贝叶斯（Streaming Variational Bayes）同源，实际上就是把后者搬到了深度网络上。这也解释了为什么它"自动"——整个框架没有任何需要验证集调节的旋钮，这在在线场景中是很大的工程优势。

> ⭐ **一句话总结**：VCL 证明了"持续学习 = 贝叶斯推断"——把上一个任务的后验当作下一个任务的先验，用变分推断自动完成知识保留，再用核心集作为情景记忆弥补近似误差，在判别与生成模型上都达到了当时的最优水平，且无需任何超参数调节。

## 参考文献

- Nguyen, C. V., Li, Y., Bui, T. D., & Turner, R. E. (2018). Variational Continual Learning. *ICLR 2018*.
- Kirkpatrick, J., et al. (2017). Overcoming catastrophic forgetting in neural networks. *PNAS*.
- Zenke, F., Poole, B., & Ganguli, S. (2017). Continual Learning Through Synaptic Intelligence. *ICML*.
- Blundell, C., et al. (2015). Weight Uncertainty in Neural Networks. *ICML*.
- Gonzalez, T. F. (1985). Clustering to minimize the maximum intercluster distance. *Theoretical Computer Science*.
