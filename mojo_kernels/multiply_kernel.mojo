{
  "cells": [
    {
      "cell_type": "code",
      "source": [
        "!nvcc --version"
      ],
      "metadata": {
        "id": "bSI44f7M-hWp"
      },
      "execution_count": null,
      "outputs": []
    },
    {
      "cell_type": "code",
      "source": [
        "!nvidia-smi"
      ],
      "metadata": {
        "id": "cTOmTYZa-jBx"
      },
      "execution_count": null,
      "outputs": []
    },
    {
      "cell_type": "code",
      "source": [
        "!curl -ssL https://magic.modular.com/ | bash"
      ],
      "metadata": {
        "id": "qr8tmarU-p64"
      },
      "execution_count": null,
      "outputs": []
    },
    {
      "cell_type": "code",
      "source": [
        "import os\n",
        "os.environ['PATH'] += ':/root/.modular/bin'"
      ],
      "metadata": {
        "id": "u22u-EjZ-u6I"
      },
      "execution_count": null,
      "outputs": []
    },
    {
      "cell_type": "code",
      "source": [
        "!magic init mojo_kernels --format mojoproject"
      ],
      "metadata": {
        "id": "MEJigwCb-yxY"
      },
      "execution_count": null,
      "outputs": []
    },
    {
      "cell_type": "code",
      "source": [
        "%cd mojo_kernels/"
      ],
      "metadata": {
        "id": "Ccp3B2mc-3xB"
      },
      "execution_count": null,
      "outputs": []
    },
    {
      "cell_type": "code",
      "source": [
        "!magic run mojo --version"
      ],
      "metadata": {
        "id": "wSS-8F2J-5OA"
      },
      "execution_count": null,
      "outputs": []
    },
    {
      "cell_type": "code",
      "source": [
        "%%writefile multiply_kernel.mojo\n",
        "\n",
        "from gpu import thread_idx, block_idx\n",
        "from gpu.host import DeviceContext\n",
        "from layout import Layout, LayoutTensor\n",
        "from math import iota\n",
        "\n",
        "alias dtype = DType.uint32\n",
        "alias blocks = 4\n",
        "alias threads = 4\n",
        "alias layout = Layout.row_major(blocks, threads)\n",
        "var in_elements = blocks * threads\n",
        "alias InTensor = LayoutTensor[dtype, layout, MutableAnyOrigin]\n",
        "\n",
        "fn multiply_kernel[factor: Int](in_tensor: InTensor):\n",
        "  in_tensor[block_idx.x, thread_idx.x] *= factor\n",
        "\n",
        "fn main() raises:\n",
        "  ctx = DeviceContext()\n",
        "  in_buffer = ctx.enqueue_create_buffer[dtype](in_elements)\n",
        "  with in_buffer.map_to_host() as host_buffer:\n",
        "    iota(host_buffer.unsafe_ptr(), in_elements)\n",
        "    print(host_buffer)\n",
        "\n",
        "  in_tensor = InTensor(in_buffer)\n",
        "\n",
        "  ctx.enqueue_function[multiply_kernel[2]](in_tensor, grid_dim=blocks, block_dim=threads)\n",
        "\n",
        "  print(in_buffer) #Printing works without context!\n",
        "  #print(InTensor(in_buffer))# This does not work though\n",
        "  with in_buffer.map_to_host() as host_buffer: #Let's go by the books\n",
        "    host_tensor = InTensor(host_buffer)\n",
        "    print(host_tensor)\n",
        "\n",
        "  ctx.synchronize()\n",
        "  #print(in_tensor) # Error\n",
        "\n",
        "  print(\"In buffer created!\")\n",
        "\n"
      ],
      "metadata": {
        "id": "bJAK2l2t_XBR",
        "outputId": "0c92f1d8-377d-48fc-d3a4-b73c89b3b933",
        "colab": {
          "base_uri": "https://localhost:8080/"
        }
      },
      "execution_count": 33,
      "outputs": [
        {
          "output_type": "stream",
          "name": "stdout",
          "text": [
            "Overwriting multiply_kernel.mojo\n"
          ]
        }
      ]
    },
    {
      "cell_type": "code",
      "source": [
        "!magic run mojo multiply_kernel.mojo"
      ],
      "metadata": {
        "id": "jXIyS5ZHBsXJ",
        "outputId": "f360a8af-42ef-429c-e902-a5663cd339f9",
        "colab": {
          "base_uri": "https://localhost:8080/"
        }
      },
      "execution_count": 34,
      "outputs": [
        {
          "output_type": "stream",
          "name": "stdout",
          "text": [
            "\u001b[32m⠁\u001b[0m                                                                               \r\u001b[2K\u001b[32m⠁\u001b[0m activating environment                                                        \r\u001b[2K\u001b[32m⠁\u001b[0m activating environment                                                        \r\u001b[2KHostBuffer([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15])\n",
            "DeviceBuffer([0, 2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30])\n",
            "0 2 4 6 \n",
            "8 10 12 14 \n",
            "16 18 20 22 \n",
            "24 26 28 30 \n",
            "In buffer created!\n"
          ]
        }
      ]
    }
  ],
  "metadata": {
    "colab": {
      "name": "Welcome To Colab",
      "provenance": [],
      "gpuType": "T4"
    },
    "kernelspec": {
      "display_name": "Python 3",
      "name": "python3"
    },
    "accelerator": "GPU"
  },
  "nbformat": 4,
  "nbformat_minor": 0
}
