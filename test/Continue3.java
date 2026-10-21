class Continue3 {
    public static void main(String[] args) {
        outer:
        for (int i = 0; i < 4; i++) {
            for (int j = 0; j < 4; j++) {
                if (j == 2) {
                    continue outer;
                }
                System.out.println(i * 10 + j);
            }
            System.out.println(-1);
        }
        System.out.println("done");
    }
}
