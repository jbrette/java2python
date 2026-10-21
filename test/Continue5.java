class Continue5 {
    public static void main(String[] args) {
        int i = 0;
        outer:
        do {
            i++;
            for (int j = 0; j < 4; j++) {
                if (j == 2) {
                    continue outer;
                }
                System.out.println(i * 10 + j);
            }
            System.out.println(-1);
        } while (i < 4);
        System.out.println("done");
    }
}
