class ForEach1 {
    public static void main(String[] args) {
        int ints[] = {1, 2, 3, 4};
        outer:
        for (int i: ints) {
            for (int j: ints) {
                if (j == 3) {
                    continue outer;
                }
                if (i == 4) {
                    break outer;
                }
                System.out.println(i * 10 + j);
            }
            System.out.println(-1);
        }
        System.out.println("done");
    }
}
