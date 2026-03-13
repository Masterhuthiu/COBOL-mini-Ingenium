name: Build and Push Docker Image

on:
  push:
    branches:
      - main
  pull_request:
    branches:
      - main

jobs:
  build-and-push:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout source code
        uses: actions/checkout@v4

      - name: Login to DockerHub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKER_USER }}
          password: ${{ secrets.DOCKER_PASS }}

      - name: Set up Image Metadata
        id: meta
        run: |
          # Chuyển DOCKER_USER về chữ thường để tránh lỗi "invalid reference format"
          LOW_USER=$(echo "${{ secrets.DOCKER_USER }}" | tr '[:upper:]' '[:lower:]')
          IMAGE_NAME="$LOW_USER/mini-ingenium"
          echo "IMAGE_TAG=$IMAGE_NAME:latest" >> $GITHUB_ENV
          echo "IMAGE_NAME=$IMAGE_NAME" >> $GITHUB_ENV

      - name: Build and Push Docker Image
        uses: docker/build-push-action@v5
        with:
          context: .
          file: ./Dockerfile
          push: true
          tags: ${{ env.IMAGE_TAG }}
          # Cache giúp build nhanh hơn ở các lần sau
          cache-from: type=gha
          cache-to: type=gha,mode=max

      - name: Image Summary
        run: |
          echo "Successfully pushed to: ${{ env.IMAGE_TAG }}"